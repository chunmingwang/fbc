'' Test visibility declaring (DIM) a variable from outside
'' a type containing nested (inner scoped) types 3 levels deep
'' within a local scope
''
'' each combination of public, protected, private is checked for
'' each nested level requiring 3*3*3=27 cases
''
''
''
''

#define msg(lineno,arg) "Expect error to follow @" lineno,arg
#macro t( iserror, arg, statement )
	#if( iserror <> 0 )
		#print msg(__LINE__,arg)
	#endif
	statement
#endmacro

#macro decl_T( basename, scope1, scope2, scope3 )
	type basename##0
		scope1:
			i1 as integer
			type basename##1
				scope2:
					i2 as integer
					type basename##2
						scope3:
							i3 as integer
							type basename##3
								d as integer
							end type
							m3 as basename##3
					end type
					m2 as basename##2
			end type
			m1 as basename##1
	end type
#endmacro

#macro test_X0( basename, r1, r2, r3, r4, r5 )
	t( r1, 1, dim x0 as basename##0 )
	t( r2, 2, x0.i1 = 1 )
	t( r3, 3, x0.m1.i2 = 1 )
	t( r4, 4, x0.m1.m2.i3 = 1 )
	t( r5, 5, x0.m1.m2.m3.d = 1 )
#endmacro
#macro test_X1( basename, r1, r2, r3, r4 )
	t( r1, 1, dim x1 as basename##0.basename##1 )
	t( r2, 2, x1.i2 = 1 )
	t( r3, 3, x1.m2.i3 = 1 )
	t( r4, 4, x1.m2.m3.d = 1 )
#endmacro
#macro test_X2( basename, r1, r2, r3 )
	t( r1, 1, dim x2 as basename##0.basename##1.basename##2 )
	t( r2, 2, x2.i3 = 1 )
	t( r3, 3, x2.m3.d = 1 )
#endmacro
#macro test_X3( basename, r1, r2 )
	t( r1, 1, dim x3 as basename##0.basename##1.basename##2.basename##3 )
	t( r2, 2, x3.d = 1 )
#endmacro

#print "---------- public/public/public"
scope
	decl_T( UDT01, public, public, public )
	test_X0( UDT01, 0, 0, 0, 0, 0 )
	test_X1( UDT01,    0, 0, 0, 0 )
	test_X2( UDT01,       0, 0, 0 )
	test_X3( UDT01,          0, 0 )
end scope


#print "---------- public/public/protected"
scope
	decl_T( UDT02, public, public, protected )
	test_X0( UDT02, 0, 0, 0, 1, 1 )
	test_X1( UDT02,    0, 0, 1, 1 )
	test_X2( UDT02,       0, 1, 1 )
	test_X3( UDT02,          1, 1 )
end scope

#print "---------- public/public/private"
scope
	decl_T( UDT03, public, public, private )
	test_X0( UDT03, 0, 0, 0, 1, 1 )
	test_X1( UDT03,    0, 0, 1, 1 )
	test_X2( UDT03,       0, 1, 1 )
	test_X3( UDT03,          1, 1 )
end scope

#print "---------- public/protected/public"
scope
	decl_T( UDT04, public, protected, public )
	test_X0( UDT04, 0, 0, 1, 1, 1 )
	test_X1( UDT04,    0, 1, 1, 1 )
	test_X2( UDT04,       1, 1, 1 )
	test_X3( UDT04,          1, 1 )
end scope

#print "---------- public/protected/protected"
scope
	decl_T( UDT05, public, protected, protected )
	test_X0( UDT05, 0, 0, 1, 1, 1 )
	test_X1( UDT05,    0, 1, 1, 1 )
	test_X2( UDT05,       1, 1, 1 )
	test_X3( UDT05,          1, 1 )
end scope

#print "---------- public/protected/private"
scope
	decl_T( UDT06, public, protected, private )
	test_X0( UDT06, 0, 0, 1, 1, 1 )
	test_X1( UDT06,    0, 1, 1, 1 )
	test_X2( UDT06,       1, 1, 1 )
	test_X3( UDT06,          1, 1 )
end scope

#print "---------- public/private/public"
scope
	decl_T( UDT07, public, private, public )
	test_X0( UDT07, 0, 0, 1, 1, 1 )
	test_X1( UDT07,    0, 1, 1, 1 )
	test_X2( UDT07,       1, 1, 1 )
	test_X3( UDT07,          1, 1 )
end scope

#print "---------- public/private/protected"
scope
	decl_T( UDT08, public, private, protected )
	test_X0( UDT08, 0, 0, 1, 1, 1 )
	test_X1( UDT08,    0, 1, 1, 1 )
	test_X2( UDT08,       1, 1, 1 )
	test_X3( UDT08,          1, 1 )
end scope

#print "---------- public/private/private"
scope
	decl_T( UDT09, public, private, private )
	test_X0( UDT09, 0, 0, 1, 1, 1 )
	test_X1( UDT09,    0, 1, 1, 1 )
	test_X2( UDT09,       1, 1, 1 )
	test_X3( UDT09,          1, 1 )
end scope

#print "---------- protected/public/public"
scope
	decl_T( UDT10, protected, public, public )
	test_X0( UDT10, 0, 1, 1, 1, 1 )
	test_X1( UDT10,    1, 1, 1, 1 )
	test_X2( UDT10,       1, 1, 1 )
	test_X3( UDT10,          1, 1 )
end scope

#print "---------- protected/public/protected"
scope
	decl_T( UDT11, protected, public, protected )
	test_X0( UDT11, 0, 1, 1, 1, 1 )
	test_X1( UDT11,    1, 1, 1, 1 )
	test_X2( UDT11,       1, 1, 1 )
	test_X3( UDT11,          1, 1 )
end scope

#print "---------- protected/public/private"
scope
	decl_T( UDT12, protected, public, private )
	test_X0( UDT12, 0, 1, 1, 1, 1 )
	test_X1( UDT12,    1, 1, 1, 1 )
	test_X2( UDT12,       1, 1, 1 )
	test_X3( UDT12,          1, 1 )
end scope

#print "---------- protected/protected/public"
scope
	decl_T( UDT13, protected, protected, public )
	test_X0( UDT13, 0, 1, 1, 1, 1 )
	test_X1( UDT13,    1, 1, 1, 1 )
	test_X2( UDT13,       1, 1, 1 )
	test_X3( UDT13,          1, 1 )
end scope

#print "---------- protected/protected/protected"
scope
	decl_T( UDT14, protected, protected, protected )
	test_X0( UDT14, 0, 1, 1, 1, 1 )
	test_X1( UDT14,    1, 1, 1, 1 )
	test_X2( UDT14,       1, 1, 1 )
	test_X3( UDT14,          1, 1 )
end scope

#print "---------- protected/protected/private"
scope
	decl_T( UDT15, protected, protected, private )
	test_X0( UDT15, 0, 1, 1, 1, 1 )
	test_X1( UDT15,    1, 1, 1, 1 )
	test_X2( UDT15,       1, 1, 1 )
	test_X3( UDT15,          1, 1 )
end scope

#print "---------- protected/private/public"
scope
	decl_T( UDT16, protected, private, public )
	test_X0( UDT16, 0, 1, 1, 1, 1 )
	test_X1( UDT16,    1, 1, 1, 1 )
	test_X2( UDT16,       1, 1, 1 )
	test_X3( UDT16,          1, 1 )
end scope

#print "---------- protected/private/protected"
scope
	decl_T( UDT17, protected, private, protected )
	test_X0( UDT17, 0, 1, 1, 1, 1 )
	test_X1( UDT17,    1, 1, 1, 1 )
	test_X2( UDT17,       1, 1, 1 )
	test_X3( UDT17,          1, 1 )
end scope

#print "---------- protected/private/private"
scope
	decl_T( UDT18, protected, private, private )
	test_X0( UDT18, 0, 1, 1, 1, 1 )
	test_X1( UDT18,    1, 1, 1, 1 )
	test_X2( UDT18,       1, 1, 1 )
	test_X3( UDT18,          1, 1 )
end scope

#print "---------- private/public/public"
scope
	decl_T( UDT19, private, public, public )
	test_X0( UDT19, 0, 1, 1, 1, 1 )
	test_X1( UDT19,    1, 1, 1, 1 )
	test_X2( UDT19,       1, 1, 1 )
	test_X3( UDT19,          1, 1 )
end scope

#print "---------- private/public/protected"
scope
	decl_T( UDT20, private, public, protected )
	test_X0( UDT20, 0, 1, 1, 1, 1 )
	test_X1( UDT20,    1, 1, 1, 1 )
	test_X2( UDT20,       1, 1, 1 )
	test_X3( UDT20,          1, 1 )
end scope

#print "---------- private/public/private"
scope
	decl_T( UDT21, private, public, private )
	test_X0( UDT21, 0, 1, 1, 1, 1 )
	test_X1( UDT21,    1, 1, 1, 1 )
	test_X2( UDT21,       1, 1, 1 )
	test_X3( UDT21,          1, 1 )
end scope

#print "---------- private/protected/public"
scope
	decl_T( UDT22, private, protected, public )
	test_X0( UDT22, 0, 1, 1, 1, 1 )
	test_X1( UDT22,    1, 1, 1, 1 )
	test_X2( UDT22,       1, 1, 1 )
	test_X3( UDT22,          1, 1 )
end scope

#print "---------- private/protected/protected"
scope
	decl_T( UDT23, private, protected, protected )
	test_X0( UDT23, 0, 1, 1, 1, 1 )
	test_X1( UDT23,    1, 1, 1, 1 )
	test_X2( UDT23,       1, 1, 1 )
	test_X3( UDT23,          1, 1 )
end scope

#print "---------- private/protected/private"
scope
	decl_T( UDT24, private, protected, private )
	test_X0( UDT24, 0, 1, 1, 1, 1 )
	test_X1( UDT24,    1, 1, 1, 1 )
	test_X2( UDT24,       1, 1, 1 )
	test_X3( UDT24,          1, 1 )
end scope

#print "---------- private/private/public"
scope
	decl_T( UDT25, private, private, public )
	test_X0( UDT25, 0, 1, 1, 1, 1 )
	test_X1( UDT25,    1, 1, 1, 1 )
	test_X2( UDT25,       1, 1, 1 )
	test_X3( UDT25,          1, 1 )
end scope

#print "---------- private/private/protected"
scope
	decl_T( UDT26, private, private, protected )
	test_X0( UDT26, 0, 1, 1, 1, 1 )
	test_X1( UDT26,    1, 1, 1, 1 )
	test_X2( UDT26,       1, 1, 1 )
	test_X3( UDT26,          1, 1 )
end scope

#print "---------- private/private/private"
scope
	decl_T( UDT27, private, private, private )
	test_X0( UDT27, 0, 1, 1, 1, 1 )
	test_X1( UDT27,    1, 1, 1, 1 )
	test_X2( UDT27,       1, 1, 1 )
	test_X3( UDT27,          1, 1 )
end scope
