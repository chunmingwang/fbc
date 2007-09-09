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


'' intermediate representation - high-level, direct to "C" output
''
'' chng: dec/2006 written [v1ctor]


#include once "inc\fb.bi"
#include once "inc\fbint.bi"
#include once "inc\ir.bi"
#include once "inc\flist.bi"

type DTYPEINFO
	class			as integer
	size			as integer
	name			as zstring * 31+1
end type

type IRHLCCTX
	identcnt		as integer
	regcnt			as integer
	vregTB			as TFLIST
end type

declare function hDtypeToStr _
	( _
		byval vreg as IRVREG ptr _
	) as zstring ptr


'' globals
	dim shared as IRHLCCTX ctx

	'' same order as FB_DATATYPE
	dim shared dtypeTB(0 to FB_DATATYPES-1) as DTYPEINFO => _
	{ _
		( FB_DATACLASS_INTEGER, 0 			    , "void"  ), _				'' void
		( FB_DATACLASS_INTEGER, 1			    , "char"  ), _				'' byte
		( FB_DATACLASS_INTEGER, 1			    , "unsigned char"  ), _		'' ubyte
		( FB_DATACLASS_INTEGER, 1               , "char"  ), _				'' char
		( FB_DATACLASS_INTEGER, 2               , "short"  ), _				'' short
		( FB_DATACLASS_INTEGER, 2               , "unsigned char"  ), _		'' ushort
		( FB_DATACLASS_INTEGER, 2  				, "short" ), _				'' wchar
		( FB_DATACLASS_INTEGER, FB_INTEGERSIZE  , "int" ), _				'' int
		( FB_DATACLASS_INTEGER, FB_INTEGERSIZE  , "unsigned int" ), _   	'' uint
		( FB_DATACLASS_INTEGER, FB_INTEGERSIZE  , "int" ), _				'' enum
		( FB_DATACLASS_INTEGER, FB_INTEGERSIZE  , "int" ), _				'' bitfield
		( FB_DATACLASS_INTEGER, FB_LONGSIZE  	, "long" ), _				'' long
		( FB_DATACLASS_INTEGER, FB_LONGSIZE  	, "unsigned long" ), _   	'' ulong
		( FB_DATACLASS_INTEGER, FB_INTEGERSIZE*2, "long long" ), _			'' longint
		( FB_DATACLASS_INTEGER, FB_INTEGERSIZE*2, "unsigned long long" ), _	'' ulongint
		( FB_DATACLASS_FPOINT , 4			    , "float" ), _				'' single
		( FB_DATACLASS_FPOINT , 8			    , "double" ), _				'' double
		( FB_DATACLASS_STRING , FB_STRDESCLEN	, ""          ), _			'' string
		( FB_DATACLASS_STRING , 1               , "char"  ), _				'' fix-len string
		( FB_DATACLASS_INTEGER, FB_INTEGERSIZE  , "void *" ), _				'' struct
		( FB_DATACLASS_INTEGER, 0  				, "" 		), _			'' namespace
		( FB_DATACLASS_INTEGER, FB_INTEGERSIZE  , "void *" ), _				'' function
		( FB_DATACLASS_INTEGER, 1			    , "void *"  ), _			'' fwd-ref
		( FB_DATACLASS_INTEGER, FB_POINTERSIZE  , "void *" ) _				'' pointer
	}

'':::::
private function _init _
	( _
		byval backend as FB_BACKEND _
	) as integer

	flistNew( @ctx.vregTB, IR_INITVREGNODES, len( IRVREG ) )

	irSetOption( IR_OPT_HIGHLEVEL or _
				 IR_OPT_CPU_BOPSELF or _
				 IR_OPT_REUSEOPER or _
				 IR_OPT_IMMOPER or _
				 IR_OPT_FPU_IMMOPER _
	 		   )

	function = TRUE

end function

'':::::
private sub _end

	flistFree( @ctx.vregTB )

end sub

'':::::
private function _emitBegin _
	( _
	) as integer

	if( hFileExists( env.outf.name ) ) then
		kill env.outf.name
	end if

	env.outf.num = freefile
	if( open( env.outf.name, for binary, access read write, as #env.outf.num ) <> 0 ) then
		return FALSE
	end if

	ctx.identcnt = 0
	ctx.regcnt = 0

	function = TRUE

end function

'':::::
private sub _emitEnd _
	( _
		byval tottime as double _
	)

	''
	if( close( #env.outf.num ) <> 0 ) then
		'' ...
	end if

	env.outf.num = 0

end sub

'':::::
private sub _emit _
	( _
		byval op as integer, _
		byval v1 as IRVREG ptr, _
		byval v2 as IRVREG ptr, _
		byval vr as IRVREG ptr, _
		byval ex1 as FBSYMBOL ptr = NULL, _
		byval ex2 as integer = 0 _
	)

end sub

'':::::
private sub hWriteLine _
	( _
		byval s as zstring ptr, _
		byval addcommas as integer = TRUE _
	)

	static as string ln

	if( ctx.identcnt > 0 ) then
		ln = string( ctx.identcnt, TABCHAR )
		ln += *s
	else
		ln = *s
	end if

	if( addcommas ) then
		ln += ";"
	end if

	ln += NEWLINE

	if( put( #env.outf.num, , ln ) <> 0 ) then
	end if

end sub

'':::::
private sub _procBegin _
	( _
		byval proc as FBSYMBOL ptr _
	)

end sub

'':::::
private sub _procEnd _
	( _
		byval proc as FBSYMBOL ptr _
	)

end sub

''::::
private function _procAllocArg _
	( _
		byval proc as FBSYMBOL ptr, _
		byval lgt as integer _
	) as integer

	function = 0

end function

'':::::
private function _procAllocLocal _
	( _
		byval proc as FBSYMBOL ptr, _
		byval lgt as integer _
	) as integer

	function = 0

end function

'':::::
private function _procGetFrameRegName _
	( _
	) as zstring ptr

	function = NULL

end function

'':::::
private sub _scopeBegin _
	( _
		byval s as FBSYMBOL ptr _
	)

end sub

'':::::
private sub _scopeEnd _
	( _
		byval s as FBSYMBOL ptr _
	)

end sub

'':::::
private function _procAllocStatVars _
	( _
		byval head_sym as FBSYMBOL ptr _
	) as integer

	function = 0

end function

''::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

'':::::
private function hNewVR _
	( _
		byval dtype as integer, _
		byval subtype as FBSYMBOL ptr, _
		byval vtype as integer _
	) as IRVREG ptr

	dim as IRVREG ptr v = any

	v = flistNewItem( @ctx.vregTB )

	v->typ = vtype
	v->dtype = dtype
	v->subtype = subtype
	v->sym = NULL
	v->reg = INVALID
	v->vidx	= NULL
	v->ofs = 0

	function = v

end function

'':::::
private function _allocVreg _
	( _
		byval dtype as integer, _
		byval subtype as FBSYMBOL ptr _
	) as IRVREG ptr

	function = hNewVR( dtype, subtype, IR_VREGTYPE_REG )

end function

'':::::
private function _allocVrImm _
	( _
		byval dtype as integer, _
		byval subtype as FBSYMBOL ptr, _
		byval value as integer _
	) as IRVREG ptr

	dim as IRVREG ptr vr = hNewVR( dtype, subtype, IR_VREGTYPE_IMM )

	vr->value.int = value

	function = vr

end function

'':::::
private function _allocVrImm64 _
	( _
		byval dtype as integer, _
		byval subtype as FBSYMBOL ptr, _
		byval value as longint _
	) as IRVREG ptr

	dim as IRVREG ptr vr = hNewVR( dtype, subtype, IR_VREGTYPE_IMM )

	vr->value.long = value

	function = vr

end function

'':::::
private function _allocVrImmF _
	( _
		byval dtype as integer, _
		byval subtype as FBSYMBOL ptr, _
		byval value as double _
	) as IRVREG ptr

	dim as IRVREG ptr vr = hNewVR( dtype, subtype, IR_VREGTYPE_IMM )

	vr->value.float = value

	function = vr

end function

'':::::
private function _allocVrVar _
	( _
		byval dtype as integer, _
		byval subtype as FBSYMBOL ptr, _
		byval symbol as FBSYMBOL ptr, _
		byval ofs as integer _
	) as IRVREG ptr

	dim as IRVREG ptr vr = hNewVR( dtype, subtype, IR_VREGTYPE_VAR )

	vr->sym = symbol
	vr->ofs = ofs

	function = vr

end function

'':::::
private function _allocVrIdx _
	( _
		byval dtype as integer, _
		byval subtype as FBSYMBOL ptr, _
		byval symbol as FBSYMBOL ptr, _
		byval ofs as integer, _
		byval mult as integer, _
		byval vidx as IRVREG ptr _
	) as IRVREG ptr

	dim as IRVREG ptr vr = hNewVR( dtype, subtype, IR_VREGTYPE_IDX )

	vr->sym = symbol
	vr->ofs = ofs
	vr->mult = mult
	vr->vidx = vidx

	function = vr

end function

'':::::
private function _allocVrPtr _
	( _
		byval dtype as integer, _
		byval subtype as FBSYMBOL ptr, _
		byval ofs as integer, _
		byval vidx as IRVREG ptr _
	) as IRVREG ptr

	dim as IRVREG ptr vr = hNewVR( dtype, subtype, IR_VREGTYPE_PTR )

	vr->ofs = ofs
	vr->mult = 1
	vr->vidx = vidx

	function = vr

end function

'':::::
private function _allocVrOfs _
	( _
		byval dtype as integer, _
		byval subtype as FBSYMBOL ptr, _
		byval symbol as FBSYMBOL ptr, _
		byval ofs as integer _
	) as IRVREG ptr

	dim as IRVREG ptr vr = hNewVR( dtype, subtype, IR_VREGTYPE_OFS )

	vr->sym = symbol
	vr->ofs = ofs

	function = vr

end function

'':::::
private sub _setVregDataType _
	( _
		byval vreg as IRVREG ptr, _
		byval dtype as integer, _
		byval subtype as FBSYMBOL ptr _
	)

	if( vreg <> NULL ) then
		vreg->dtype = dtype
		vreg->subtype = subtype
	end if

end sub

'':::::
private sub hLoadVreg _
	( _
		byval vreg as IRVREG ptr _
	)

	if( vreg = NULL ) then
		exit sub
	end if

	'' reg?
	if( vreg->typ = IR_VREGTYPE_REG ) then
		if( vreg->reg <> INVALID ) then
			exit sub
		end if

		vreg->reg = ctx.regcnt
		ctx.regcnt += 1

    	hWriteLine( *hDtypeToStr( vreg ) & " fb$" & vreg->reg )
    end if

    '' index?
    if( vreg->vidx <> NULL ) then
    	hLoadVreg( vreg->vidx )
    end if

end sub

''::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

'':::::
private function hDtypeToStr _
	( _
		byval vreg as IRVREG ptr _
	) as zstring ptr

	static as string res

	dim as integer dtype = typeGetDatatype( vreg->dtype )

	res = dtypeTb(dtype).name

	if( dtype = FB_DATATYPE_POINTER ) then
		for i as integer = 0 to typeGetPtrCnt( vreg->dtype ) - 1
			res += "*"
		next
	end if

	function = strptr( res )

end function

'':::::
private function hVregToStr _
	( _
		byval vreg as IRVREG ptr _
	) as string

	select case as const vreg->typ
	case IR_VREGTYPE_VAR, IR_VREGTYPE_IDX, IR_VREGTYPE_PTR
        dim as string operand

		dim as integer do_deref = any

		'' type casting?
		if( vreg->dtype <> symbGetType( vreg->sym ) or _
		    vreg->subtype <> symbGetSubType( vreg->sym ) ) then
			operand = "*(" + *hDtypeToStr( vreg ) + " *)(&"
			do_deref = TRUE

		else
			do_deref = (vreg->ofs <> 0) or (vreg->vidx <> NULL)

			if( do_deref ) then
				operand += "*(&"
			end if
		end if

		operand += *symbGetMangledName( vreg->sym )

		if( vreg->vidx <> NULL ) then
			operand += "+"
			operand += hVregToStr( vreg->vidx )
		end if

		'' offset?
		if( vreg->ofs <> 0 ) then
			operand += "+"
			operand += str( vreg->ofs )
		end if

		if( do_deref ) then
			operand += ")"
		end if

		return operand

	case IR_VREGTYPE_OFS
		dim as string operand = "&"
		operand += *symbGetMangledName( vreg->sym )
		if( vreg->ofs <> 0 ) then
			operand += " + "
			operand += str( vreg->ofs )
		end if

		return operand

	case IR_VREGTYPE_IMM
		select case as const vreg->dtype
		case FB_DATATYPE_LONGINT, FB_DATATYPE_ULONGINT
			return str( vreg->value.long )

		case FB_DATATYPE_SINGLE, FB_DATATYPE_DOUBLE
			return str( vreg->value.float )

		case else
			return str( vreg->value.int )
		end select

	case IR_VREGTYPE_REG
		return "fb$" & vreg->reg

	case else
    	return ""
	end select

end function

''::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

'':::::
private sub _emitLabel _
	( _
		byval label as FBSYMBOL ptr _
	)

end sub

'':::::
private sub _emitReturn _
	( _
		byval bytestopop as integer _
	)

end sub

'':::::
private sub _emitProcBegin _
	( _
		byval proc as FBSYMBOL ptr, _
		byval initlabel as FBSYMBOL ptr _
	)

	hWriteLine( symbGetMangledName( proc ), FALSE )
	hWriteLine( "{", FALSE )
	ctx.identcnt += 1

end sub

'':::::
private sub _emitProcEnd _
	( _
		byval proc as FBSYMBOL ptr, _
		byval initlabel as FBSYMBOL ptr, _
		byval exitlabel as FBSYMBOL ptr _
	)

	ctx.identcnt -= 1
	hWriteLine( "}", FALSE )

end sub

'':::::
private sub _emitScopeBegin _
	( _
		byval s as FBSYMBOL ptr _
	)

	hWriteLine( "{", FALSE )
	ctx.identcnt += 1

end sub

'':::::
private sub _emitScopeEnd _
	( _
		byval s as FBSYMBOL ptr _
	)

	ctx.identcnt -= 1
	hWriteLine( "}", FALSE )

end sub

''::::
private sub _emitJmpTb _
	( _
		byval dtype as integer, _
		byval label as FBSYMBOL ptr _
	)

end sub

'':::::
private sub _emitInfoSection _
	( _
		byval liblist as TLIST ptr, _
		byval libpathlist as TLIST ptr _
	)

end sub

'':::::
private sub hWriteBOP _
	( _
		byref op as string, _
		byref vrs as string, _
		byref v1s as string, _
		byref v2s as string _
	)

	hWriteLine( vrs & " = " & v1s & op & v2s )

end sub

'':::::
private sub _emitBopEx _
	( _
		byval op as integer, _
		byval v1 as IRVREG ptr, _
		byval v2 as IRVREG ptr, _
		byval vr as IRVREG ptr, _
		byval ex as FBSYMBOL ptr _
	)

	hLoadVreg( v1 )
	hLoadVreg( v2 )

	dim as string v1s = hVregToStr( v1 )
	dim as string v2s = hVregToStr( v2 )
	dim as string vrs

    if( vr <> NULL ) then
		if( v1 <> vr ) then
			hLoadVreg( vr )
			vrs = hVregToStr( vr )
		else
			vrs = v1s
		end if

	else
		vrs = v1s
	end if

	select case as const op
	case AST_OP_ADD
		hWriteBOP( "+", vrs, v1s, v2s )

	case AST_OP_SUB
		hWriteBOP( "-", vrs, v1s, v2s )

	case AST_OP_MUL
		hWriteBOP( "*", vrs, v1s, v2s )

	case AST_OP_DIV
		hWriteBOP( "/", vrs, v1s, v2s )

	case AST_OP_INTDIV
		hWriteBOP( "/", vrs, v1s, v2s )

	case AST_OP_MOD
		hWriteBOP( "%", vrs, v1s, v2s )

	case AST_OP_SHL
		hWriteBOP( "<<", vrs, v1s, v2s )

	case AST_OP_SHR
		hWriteBOP( ">>", vrs, v1s, v2s )

	case AST_OP_AND
		hWriteBOP( "&", vrs, v1s, v2s )

	case AST_OP_OR
		hWriteBOP( "|", vrs, v1s, v2s )

	case AST_OP_XOR
		hWriteBOP( "^", vrs, v1s, v2s )

	case AST_OP_EQV
		hWriteBOP( "^", vrs, v1s, v2s )
		hWriteLine( vrs & " = ~" & vrs )

	case AST_OP_IMP
		hWriteLine( vrs & " = ~" & v1s )
		hWriteBOP( "|", vrs, vrs, v2s )

	case AST_OP_ATAN2
		'' mark C's atn2() as used

    case AST_OP_POW
    	'' mark C's pow() as used

	end select

end sub

'':::::
private sub _emitBop _
	( _
		byval op as integer, _
		byval v1 as IRVREG ptr, _
		byval v2 as IRVREG ptr, _
		byval vr as IRVREG ptr _
	)

	_emitBopEx( op, v1, v2, vr, NULL )

end sub

'':::::
private sub _emitUop _
	( _
		byval op as integer, _
		byval v1 as IRVREG ptr, _
		byval vr as IRVREG ptr _
	)

	hLoadVreg( v1 )

    dim as string v1s = hVregToStr( v1 )
    dim as string vrs

    if( vr <> NULL ) then
		if( v1 <> vr ) then
			hLoadVreg( vr )
			vrs = hVregToStr( vr )
		else
			vrs = v1s
		end if

	else
		vrs = v1s
	end if

	select case as const op
	case AST_OP_NEG
		hWriteLine( vrs & " = -" & v1s )

	case AST_OP_NOT
		hWriteLine( vrs & " = ~" & v1s )

	case AST_OP_ABS
		'' mark C's abs() or fbas() as used

	case AST_OP_SGN
		'' mark fb_sgn#() as used

	case AST_OP_FIX
		'' ...

	case AST_OP_FRAC

	case AST_OP_SIN
		'' mark C's sin() as used

	case AST_OP_ASIN

	case AST_OP_COS

	case AST_OP_ACOS

	case AST_OP_TAN

	case AST_OP_ATAN

	case AST_OP_SQRT

	case AST_OP_LOG

	case AST_OP_EXP

	case AST_OP_FLOOR

	end select

end sub

'':::::
private sub _emitConvert _
	( _
		byval dtype as integer, _
		byval subtype as FBSYMBOL ptr, _
		byval v1 as IRVREG ptr, _
		byval v2 as IRVREG ptr _
	)

end sub

'':::::
private sub _emitStore _
	( _
		byval v1 as IRVREG ptr, _
		byval v2 as IRVREG ptr _
	)

	if( v1 <> v2 ) then
		hLoadVreg( v1 )
		hLoadVreg( v2 )
		hWriteLine( hVregToStr( v1 ) & " = " & hVregToStr( v2 ) )
	end if

end sub

'':::::
private sub _emitSpillRegs _
	( _
	)

end sub

'':::::
private sub _emitLoad _
	( _
		byval v1 as IRVREG ptr _
	)

end sub

'':::::
private sub _emitLoadRes _
	( _
		byval v1 as IRVREG ptr, _
		byval vr as IRVREG ptr _
	)

end sub

'':::::
private sub _emitStack _
	( _
		byval op as integer, _
		byval v1 as IRVREG ptr _
	)

end sub

'':::::
private sub _emitPushUDT _
	( _
		byval v1 as IRVREG ptr, _
		byval lgt as integer _
	)

end sub

'':::::
private sub _emitPushArg _
	( _
		byval vr as IRVREG ptr, _
		byval plen as integer _
	)

end sub

'':::::
private sub _emitAddr _
	( _
		byval op as integer, _
		byval v1 as IRVREG ptr, _
		byval vr as IRVREG ptr _
	)

end sub

'':::::
private sub _emitLabelNF _
	( _
		byval l as FBSYMBOL ptr _
	)

end sub

'':::::
private sub _emitCall _
	( _
		byval proc as FBSYMBOL ptr, _
		byval bytestopop as integer, _
		byval vr as IRVREG ptr _
	)

end sub

'':::::
private sub _emitCallPtr _
	( _
		byval v1 as IRVREG ptr, _
		byval vr as IRVREG ptr, _
		byval bytestopop as integer _
	)

end sub

'':::::
private sub _emitStackAlign _
	( _
		byval bytes as integer _
	)

end sub

'':::::
private sub _emitJumpPtr _
	( _
		byval v1 as IRVREG ptr _
	)

end sub

'':::::
private sub _emitBranch _
	( _
		byval op as integer, _
		byval label as FBSYMBOL ptr _
	)

end sub

'':::::
private sub _emitMem _
	( _
		byval op as integer, _
		byval v1 as IRVREG ptr, _
		byval v2 as IRVREG ptr, _
		byval bytes as integer _
	)

end sub

'':::::
private sub _emitDBG _
	( _
		byval op as integer, _
		byval proc as FBSYMBOL ptr, _
		byval ex as integer _
	)

end sub

'':::::
private sub _emitComment _
	( _
		byval text as zstring ptr _
	)

end sub

'':::::
private sub _emitASM _
	( _
		byval text as zstring ptr _
	)

end sub

'':::::
private sub _emitVarIniBegin _
	( _
		byval sym as FBSYMBOL ptr _
	)

end sub

'':::::
private sub _emitVarIniEnd _
	( _
		byval sym as FBSYMBOL ptr _
	)

end sub

'':::::
private sub _emitVarIniI _
	( _
		byval dtype as integer, _
		byval value as integer _
	)

end sub

'':::::
private sub _emitVarIniF _
	( _
		byval dtype as integer, _
		byval value as double _
	)

end sub

'':::::
private sub _emitVarIniI64 _
	( _
		byval dtype as integer, _
		byval value as longint _
	)

end sub

'':::::
private sub _emitVarIniOfs _
	( _
		byval sym as FBSYMBOL ptr, _
		byval ofs as integer _
	)

end sub

'':::::
private sub _emitVarIniStr _
	( _
		byval totlgt as integer, _
		byval litstr as zstring ptr, _
		byval litlgt as integer _
	)

end sub

'':::::
private sub _emitVarIniWstr _
	( _
		byval totlgt as integer, _
		byval litstr as wstring ptr, _
		byval litlgt as integer _
	)

end sub

'':::::
private sub _emitVarIniPad _
	( _
		byval bytes as integer _
	)

end sub

''::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

'':::::
private sub _flush

	flistReset( @ctx.vregTB )
	ctx.regcnt = 0

end sub

'':::::
private function _GetDistance _
	( _
		byval vreg as IRVREG ptr _
	) as uinteger

	/' unused '/

	function = 0

end function

'':::::
private sub _loadVR _
	( _
		byval reg as integer, _
		byval vreg as IRVREG ptr, _
		byval doload as integer _
	)



end sub

'':::::
private sub _storeVR _
	( _
		byval vreg as IRVREG ptr, _
		byval reg as integer _
	)

	/' unused '/

end sub

'':::::
private sub _xchgTOS _
	( _
		byval reg as integer _
	)

	/' unused '/

end sub

'':::::
function irHLC_ctor _
	( _
	) as integer

	static as IR_VTBL _vtbl = _
	( _
		@_init, _
		@_end, _
		@_flush, _
		@_emitBegin, _
		@_emitEnd, _
		@_procBegin, _
		@_procEnd, _
		@_procAllocArg, _
		@_procAllocLocal, _
		@_procGetFrameRegName, _
		@_scopeBegin, _
		@_scopeEnd, _
		@_procAllocStatVars, _
		@_emit, _
		@_emitConvert, _
		@_emitLabel, _
		@_emitLabelNF, _
		@_emitReturn, _
		@_emitProcBegin, _
		@_emitProcEnd, _
		@_emitPushArg, _
		@_emitASM, _
		@_emitComment, _
		@_emitJmpTb, _
		@_emitInfoSection, _
		@_emitBop, _
		@_emitBopEx, _
		@_emitUop, _
		@_emitStore, _
		@_emitSpillRegs, _
		@_emitLoad, _
		@_emitLoadRes, _
		@_emitStack, _
		@_emitPushUDT, _
		@_emitAddr, _
		@_emitCall, _
		@_emitCallPtr, _
		@_emitStackAlign, _
		@_emitJumpPtr, _
		@_emitBranch, _
		@_emitMem, _
		@_emitScopeBegin, _
		@_emitScopeEnd, _
		@_emitDBG, _
		@_emitVarIniBegin, _
		@_emitVarIniEnd, _
		@_emitVarIniI, _
		@_emitVarIniF, _
		@_emitVarIniI64, _
		@_emitVarIniOfs, _
		@_emitVarIniStr, _
		@_emitVarIniWstr, _
		@_emitVarIniPad, _
		@_allocVreg, _
		@_allocVrImm, _
		@_allocVrImm64, _
		@_allocVrImmF, _
		@_allocVrVar, _
		@_allocVrIdx, _
		@_allocVrPtr, _
		@_allocVrOfs, _
		@_setVregDataType, _
		@_getDistance, _
		@_loadVr, _
		@_storeVr, _
		@_xchgTOS _
	)

	ir.vtbl = _vtbl

	'errReportEx( FB_ERRMSG_INTERNAL, "the ir module for -gen gcc isn't implemented yet" )

	function = TRUE

end function
