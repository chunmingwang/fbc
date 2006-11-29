''	FreeBASIC - 32-bit BASIC Compiler.
''	Copyright (C) 2004-2007 The FreeBASIC development team.
''
''	This program is free software; you can redistribute it and/or modify
''	it under the terms of the GNU General Public License as published by
''	the Free Software Foundation; either version 2 of the License, or
''	(at your option) any later version.
''
''	This program is distributed in the hope that it will be useful,
''	but WITHOUT ANY WARRANTY; without even the implied warranty of
''	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
''	GNU General Public License for more details.
''
''	You should have received a copy of the GNU General Public License
''	along with this program; if not, write to the Free Software
''	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA.

'' AST nodes related to memory operations
'' bop (l = destine; r = source)
''
'' chng: sep/2004 written [v1ctor]


#include once "inc\fb.bi"
#include once "inc\fbint.bi"
#include once "inc\ir.bi"
#include once "inc\ast.bi"
#include once "inc\rtl.bi"

'':::::
function astNewMEM _
	( _
		byval op as integer, _
		byval l as ASTNODE ptr, _
		byval r as ASTNODE ptr, _
		byval bytes as integer _
	) as ASTNODE ptr

    dim as ASTNODE ptr n = any

	'' alloc new node
	n = astNewNode( AST_NODECLASS_MEM, INVALID )
	if( n = NULL ) then
		return NULL
	end if

	n->mem.op = op
	n->l = l
	n->r = r
	n->mem.bytes = bytes

	function = n

end function

'':::::
private function hCallCtorList _
	( _
		byval ptr_expr as ASTNODE ptr, _
		byval elmts_expr as ASTNODE ptr, _
		byval dtype as integer, _
		byval subtype as FBSYMBOL ptr _
	) as ASTNODE ptr

    dim as FBSYMBOL ptr cnt = any, label = any, iter = any
    dim as ASTNODE ptr tree = any

    cnt = symbAddTempVar( FB_DATATYPE_INTEGER, NULL, FALSE, FALSE )
    label = symbAddLabel( NULL, TRUE )
    iter = symbAddTempVar( FB_DATATYPE_POINTER + dtype, subtype, FALSE, FALSE )

	'' iter = @vector[0]
	tree = astBuildVarAssign( iter, ptr_expr )

	'' for cnt = 0 to elements-1
	tree = astBuildForBeginEx( tree, cnt, label, 0 )

	'' ctor( *iter )
	tree = astNewLINK( tree, _
					   astBuildCtorCall( subtype, astBuildVarDeref( iter ) ) )

	'' iter += 1
    tree = astNewLINK( tree, _
    				   astBuildVarInc( iter, 1 ) )

    '' next
    tree = astBuildForEndEx( tree, cnt, label, 1, elmts_expr )

	function = tree

end function

'':::::
private function hNewOp _
	( _
		byval op as AST_OP, _
		byval ptr_expr as ASTNODE ptr, _
		byval elmts_expr as ASTNODE ptr, _
		byval ctor_expr as ASTNODE ptr, _
		byval dtype as integer, _
		byval subtype as FBSYMBOL ptr _
	) as ASTNODE ptr

	dim as integer has_ctor = FALSE, save_elmts = FALSE

	select case dtype
	case FB_DATATYPE_STRUCT ', FB_DATATYPE_CLASS
		'' no explicit ctor call?
		if( ctor_expr = NULL ) then
			'' default ctor?
			has_ctor = symbGetCompDefCtor( subtype ) <> NULL
		else
			has_ctor = TRUE
		end if

		'' save elements count?
		if( op = AST_OP_NEW_VEC ) then
			save_elmts = symbGetCompDtor( subtype ) <> NULL
		end if
	end select

	dim as ASTNODE ptr tree = NULL

	dim as ASTNODE ptr new_expr = any, len_expr = any
	dim as integer clone_elmts = FALSE

	'' elms *= sizeof( typeof( expr ) )
	if( save_elmts or (has_ctor and (op = AST_OP_NEW_VEC)) ) then
		'' side-effect?
		if( astIsClassOnTree( AST_NODECLASS_CALL, elmts_expr ) <> NULL ) then
			tree = astRemSideFx( elmts_expr )
		end if

		clone_elmts = TRUE
	end if

	len_expr = astNewBOP( AST_OP_MUL, _
						  iif( clone_elmts, astCloneTree( elmts_expr ), elmts_expr ), _
						  astNewCONSTi( symbCalcLen( dtype, subtype ) + _
						  				iif( save_elmts, FB_INTEGERSIZE, 0 ), _
						  				FB_DATATYPE_UINT ) )

	''
	new_expr = rtlMemNewOp( op = AST_OP_NEW_VEC, len_expr, dtype, subtype )
	if( new_expr = NULL ) then
		return NULL
	end if

	'' save elements count?
	if( save_elmts ) then
    	'' note: assuming ptr_expr will be an ordinary temp var
    	dim as FBSYMBOL ptr tmp = astGetSymbol( ptr_expr )

    	'' ptr = new( len )
		tree = astNewLINK( tree, _
						   astBuildVarAssign( tmp, new_expr ) )

		'' *ptr = elmts
		tree = astNewLINK( tree, _
						   astNewASSIGN( astNewPTR( 0, _
						   							astNewVAR( tmp, _
						   									   0, _
						   									   FB_DATATYPE_POINTER+FB_DATATYPE_INTEGER, _
						   									   NULL ), _
                                                    FB_DATATYPE_INTEGER, _
                                                    NULL ), _
						  	iif( has_ctor and (op = AST_OP_NEW_VEC), _
						  	   	 astCloneTree( elmts_expr ), _
						  	   	 elmts_expr ) ) )

		'' ptr += len( integer )
		tree = astNewLINK( tree, _
						   astNewSelfBOP( AST_OP_ADD_SELF, _
						   	  			  astNewVAR( tmp, _
						   	  			 			 0, _
						   	  			 			 FB_DATATYPE_POINTER+FB_DATATYPE_VOID, _
						   	  			 			 NULL ), _
            			   	  			  astNewCONSTi( FB_INTEGERSIZE, FB_DATATYPE_INTEGER ), _
            			   	  			  NULL ) )

		astDelTree( ptr_expr )
		ptr_expr = astNewVAR( tmp, 0, FB_DATATYPE_POINTER+FB_DATATYPE_VOID, NULL )

    else
		'' ptr = new( len )
		tree = astNewLINK( tree, _
					   	   astNewASSIGN( iif( has_ctor, _
					  					  	  astCloneTree( ptr_expr ), _
					  					  	  ptr_expr ), _
					  	   new_expr ) )
	end if


	'' call ctors?
	if( has_ctor ) then
		'' note: ptr_expr is never a complex node, no need to check for side-effects

		if( op = AST_OP_NEW_VEC ) then
			ctor_expr = hCallCtorList( ptr_expr, _
									   elmts_expr, _
									   dtype, _
									   subtype )

		'' not a vector..
		else
			'' call default ctor?
			if( ctor_expr = NULL ) then
				ctor_expr = astBuildCtorCall( subtype, _
									  		  astBuildVarDeref( ptr_expr ) )

			'' explicit ctor call, patch it..
			else
                '' check if a ctor call (because error recovery)..
                if( astIsCALLCTOR( ctor_expr ) ) then
                	ctor_expr = astPatchCtorCall( astCALLCTORToCALL( ctor_expr ), _
                						  		  astBuildVarDeref( ptr_expr ) )
                end if
			end if
		end if

		tree = astNewLINK( tree, ctor_expr )
	end if

	function = tree

end function

'':::::
private function hCallDtorList _
	( _
		byval ptr_expr as ASTNODE ptr, _
		byval dtype as integer, _
		byval subtype as FBSYMBOL ptr _
	) as ASTNODE ptr

    dim as FBSYMBOL ptr cnt = any, label = any, iter = any, elmts = any
    dim as ASTNODE ptr tree = any, expr = any

    cnt = symbAddTempVar( FB_DATATYPE_INTEGER, NULL, FALSE, FALSE )
    label = symbAddLabel( NULL, TRUE )
    iter = symbAddTempVar( FB_DATATYPE_POINTER + dtype, subtype, FALSE, FALSE )
    elmts = symbAddTempVar( FB_DATATYPE_INTEGER, NULL, FALSE, FALSE )

	'' DELETE[]'s counter is at: cast(integer ptr, vector)[-1]

	'' elmts = cast(integer ptr, vector)[-1]
	expr = astNewPTR( 0, _
					  astNewBOP( AST_OP_ADD, _
					  			 astNewCONV( FB_DATATYPE_POINTER+FB_DATATYPE_INTEGER, _
							 			 	 NULL, _
							 			 	 astCloneTree( ptr_expr ) ), _
					  			 astNewCONSTi( -FB_INTEGERSIZE, FB_DATATYPE_INTEGER ) ), _
					  FB_DATATYPE_INTEGER, _
					  NULL )

	tree = astBuildVarAssign( elmts, expr )

	'' iter = @vector[elmts]
	ptr_expr = astNewBOP( AST_OP_ADD, _
					  	  ptr_expr, _
					  	  astNewVAR( elmts, 0, FB_DATATYPE_INTEGER, NULL ), _
					  	  NULL, _
					  	  AST_OPOPT_DEFAULT or AST_OPOPT_DOPTRARITH )

	tree = astNewLINK( tree, astBuildVarAssign( iter, ptr_expr ) )

	'' for cnt = 0 to elmts-1
	tree = astBuildForBeginEx( tree, cnt, label, 0 )

	'' iter -= 1
    tree = astNewLINK( tree, _
    				   astBuildVarInc( iter, -1 ) )

	'' dtor( *iter )
	tree = astNewLINK( tree, _
					   astBuildDtorCall( subtype, astBuildVarDeref( iter ) ) )

    '' next
    tree = astBuildForEndEx( tree, _
    						 cnt, _
    						 label, _
    						 1, _
    						 astNewVAR( elmts, 0, FB_DATATYPE_INTEGER, NULL ) )

	function = tree

end function

'':::::
private function hDelOp _
	( _
		byval op as AST_OP, _
		byval ptr_expr as ASTNODE ptr, _
		byval dtype as integer, _
		byval subtype as FBSYMBOL ptr _
	) as ASTNODE ptr

	dim as integer has_dtor = FALSE

	select case dtype
	case FB_DATATYPE_STRUCT ', FB_DATATYPE_CLASS
		has_dtor = symbGetCompDtor( subtype ) <> NULL
	end select

	dim as ASTNODE ptr tree = NULL

	'' call dtors?
	if( has_dtor ) then
		'' side-effect?
		if( astIsClassOnTree( AST_NODECLASS_CALL, ptr_expr ) <> NULL ) then
			tree = astRemSideFx( ptr_expr )
		end if

		if( op = AST_OP_DEL_VEC ) then
			tree = astNewLINK( tree, _
							   hCallDtorList( astCloneTree( ptr_expr ), _
									   		  dtype, _
									   		  subtype ) )

			'' ptr -= len( integer )
			ptr_expr = astNewBOP( AST_OP_SUB, _
								  ptr_expr, _
            			   	  	  astNewCONSTi( FB_INTEGERSIZE, _
            			   	  			  	  	FB_DATATYPE_INTEGER ) )

		'' not a vector..
		else
			tree = astNewLINK( tree, _
							   astBuildDtorCall( subtype, _
								  	astBuildVarDeref( astCloneTree( ptr_expr ) ) ) )
		end if

	end if

	'' delete( ptr )
	dim as ASTNODE ptr del_expr = any

	del_expr = rtlMemDeleteOp( op = AST_OP_DEL_VEC, ptr_expr, dtype, subtype )
	if( del_expr = NULL ) then
		return NULL
	end if

	function = astNewLINK( tree, del_expr )

end function

'':::::
function astNewMEM _
	( _
		byval op as integer, _
		byval l as ASTNODE ptr, _
		byval r as ASTNODE ptr, _
		byval ex as ASTNODE ptr, _
		byval dtype as integer, _
		byval subtype as FBSYMBOL ptr _
	) as ASTNODE ptr

    dim as ASTNODE ptr n = any

	select case as const op
	case AST_OP_NEW, AST_OP_NEW_VEC
		n = hNewOp( op, l, r, ex, dtype, subtype )

	case AST_OP_DEL, AST_OP_DEL_VEC
		n = hDelOp( op, l, dtype, subtype )

	case else
		n = astNewMEM( op, l, r, 0 )
	end select

	function = n

end function

'':::::
function astLoadMEM _
	( _
		byval n as ASTNODE ptr _
	) as IRVREG ptr

    dim as ASTNODE ptr l = any, r = any
    dim as IRVREG ptr v1 = any, v2 = any

	l = n->l
	r = n->r

	if( l = NULL ) then
		return NULL
	end if

	v1 = astLoad( l )
	astDelNode( l )

	if( r <> NULL ) then
		v2 = astLoad( r )
		astDelNode( r )
	else
		v2 = NULL
	end if

	if( ast.doemit ) then
		irEmitMEM( n->mem.op, v1, v2, n->mem.bytes )
	end if

	function = NULL

end function


