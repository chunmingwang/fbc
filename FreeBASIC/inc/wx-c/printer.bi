''
''
'' printer -- header translated with help of SWIG FB wrapper
''
'' NOTICE: This file is part of the FreeBASIC Compiler package and can't
''         be included in other distributions without authorization.
''
''
#ifndef __printer_bi__
#define __printer_bi__

#include once "wx-c/wx.bi"


declare function wxPrinter cdecl alias "wxPrinter_ctor" (byval data as wxPrintDialogData ptr) as wxPrinter ptr
declare function wxPrinter_CreateAbortWindow cdecl alias "wxPrinter_CreateAbortWindow" (byval self as wxPrinter ptr, byval parent as wxWindow ptr, byval printout as wxPrintout ptr) as wxWindow ptr
declare sub wxPrinter_ReportError cdecl alias "wxPrinter_ReportError" (byval self as wxPrinter ptr, byval parent as wxWindow ptr, byval printout as wxPrintout ptr, byval message as string)
declare function wxPrinter_GetPrintDialogData cdecl alias "wxPrinter_GetPrintDialogData" (byval self as wxPrinter ptr) as wxPrintDialogData ptr
declare function wxPrinter_GetAbort cdecl alias "wxPrinter_GetAbort" (byval self as wxPrinter ptr) as integer
declare function wxPrinter_GetLastError cdecl alias "wxPrinter_GetLastError" (byval self as wxPrinter ptr) as wxPrinterError
declare function wxPrinter_Setup cdecl alias "wxPrinter_Setup" (byval self as wxPrinter ptr, byval parent as wxWindow ptr) as integer
declare function wxPrinter_Print cdecl alias "wxPrinter_Print" (byval self as wxPrinter ptr, byval parent as wxWindow ptr, byval printout as wxPrintout ptr, byval prompt as integer) as integer
declare function wxPrinter_PrintDialog cdecl alias "wxPrinter_PrintDialog" (byval self as wxPrinter ptr, byval parent as wxWindow ptr) as wxDC ptr

type Virtual_NoParams as sub ( )
type Virtual_ParamsInt as function (byval as integer) as integer
type Virtual_OnBeginDocument as function (byval as integer, byval as integer) as integer
type Virtual_GetPageInfo as sub (byval as integer ptr, byval as integer ptr, byval as integer ptr, byval as integer ptr)

declare function wxPrintout cdecl alias "wxPrintout_ctor" (byval title as string) as wxPrintout ptr
declare sub wxPrintout_RegisterVirtual cdecl alias "wxPrintout_RegisterVirtual" (byval self as _Printout ptr, byval onBeginDocument as Virtual_OnBeginDocument, byval onEndDocument as Virtual_NoParams, byval onBeginPrinting as Virtual_NoParams, byval onEndPrinting as Virtual_NoParams, byval onPreparePrinting as Virtual_NoParams, byval hasPage as Virtual_ParamsInt, byval onPrintPage as Virtual_ParamsInt, byval getPageInfo as Virtual_GetPageInfo)
declare function wxPrintout_OnBeginDocument cdecl alias "wxPrintout_OnBeginDocument" (byval self as _Printout ptr, byval startPage as integer, byval endPage as integer) as integer
declare sub wxPrintout_OnEndDocument cdecl alias "wxPrintout_OnEndDocument" (byval self as _Printout ptr)
declare sub wxPrintout_OnBeginPrinting cdecl alias "wxPrintout_OnBeginPrinting" (byval self as _Printout ptr)
declare sub wxPrintout_OnEndPrinting cdecl alias "wxPrintout_OnEndPrinting" (byval self as _Printout ptr)
declare sub wxPrintout_OnPreparePrinting cdecl alias "wxPrintout_OnPreparePrinting" (byval self as _Printout ptr)
declare function wxPrintout_HasPage cdecl alias "wxPrintout_HasPage" (byval self as _Printout ptr, byval page as integer) as integer
declare sub wxPrintout_GetPageInfo cdecl alias "wxPrintout_GetPageInfo" (byval self as _Printout ptr, byval minPage as integer ptr, byval maxPage as integer ptr, byval pageFrom as integer ptr, byval pageTo as integer ptr)
declare function wxPrintout_GetTitle cdecl alias "wxPrintout_GetTitle" (byval self as _Printout ptr) as wxString ptr
declare function wxPrintout_GetDC cdecl alias "wxPrintout_GetDC" (byval self as _Printout ptr) as wxDC ptr
declare sub wxPrintout_SetDC cdecl alias "wxPrintout_SetDC" (byval self as _Printout ptr, byval dc as wxDC ptr)
declare sub wxPrintout_SetPageSizePixels cdecl alias "wxPrintout_SetPageSizePixels" (byval self as _Printout ptr, byval w as integer, byval h as integer)
declare sub wxPrintout_GetPageSizePixels cdecl alias "wxPrintout_GetPageSizePixels" (byval self as _Printout ptr, byval w as integer ptr, byval h as integer ptr)
declare sub wxPrintout_SetPageSizeMM cdecl alias "wxPrintout_SetPageSizeMM" (byval self as _Printout ptr, byval w as integer, byval h as integer)
declare sub wxPrintout_GetPageSizeMM cdecl alias "wxPrintout_GetPageSizeMM" (byval self as _Printout ptr, byval w as integer ptr, byval h as integer ptr)
declare sub wxPrintout_SetPPIScreen cdecl alias "wxPrintout_SetPPIScreen" (byval self as _Printout ptr, byval x as integer, byval y as integer)
declare sub wxPrintout_GetPPIScreen cdecl alias "wxPrintout_GetPPIScreen" (byval self as _Printout ptr, byval x as integer ptr, byval y as integer ptr)
declare sub wxPrintout_SetPPIPrinter cdecl alias "wxPrintout_SetPPIPrinter" (byval self as _Printout ptr, byval x as integer, byval y as integer)
declare sub wxPrintout_GetPPIPrinter cdecl alias "wxPrintout_GetPPIPrinter" (byval self as _Printout ptr, byval x as integer ptr, byval y as integer ptr)
declare function wxPrintout_IsPreview cdecl alias "wxPrintout_IsPreview" (byval self as _Printout ptr) as integer
declare sub wxPrintout_SetIsPreview cdecl alias "wxPrintout_SetIsPreview" (byval self as _Printout ptr, byval p as integer)

#endif
