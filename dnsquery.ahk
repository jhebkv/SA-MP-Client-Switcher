; ==================================================================================================================================
; Function:
;     Query DNS to get the IPv4 address(es) for the given host/domain name or vice versa.
; Parameters:
;     AddrOrName  -  host/domain name or IPv4 address (xxx.xxx.xxx.xxx).
;     ResultArray -  optional array to retrieve multiple answers.
;     CNAME       -  optional variable to retrieve the 'canonical name' (CNAME) returned from DNS for host/domain name queries.
; Return values:
;     On success: First returned address or name.
;     On failure: an empty string, ErrorLevel is set to the DNS error code.
; License:
;     The Unlicense (for details see http://unlicense.org/).
; MSDN:
;     DnsQuery   -> msdn.microsoft.com/en-us/library/ms682016(v=vs.85).aspx
;     DNS_RECORD -> msdn.microsoft.com/en-us/library/ms682082(v=vs.85).aspx
; DNS record types:
;     DNS_TYPE_A = 0x01, DNS_TYPE_CNAME = 0x05, DNS_TYPE_PTR = 0x0C
; DNS record options:
;     DNS_QUERY_STANDARD = 0, DNS_QUERY_USE_TCP_ONLY = 0x02, DNS_QUERY_BYPASS_CACHE = 0x08, DNS_QUERY_NO_HOSTS_FILE = 0x40
;     DNS_QUERY_WIRE_ONLY = 0x0100
; DNS_FREE_TYPE:
;     DnsFreeRecordList = 1
; ==================================================================================================================================
DNSQuery(AddrOrName, ByRef ResultArray := "", ByRef CNAME := "") {
   Static OffRR := (A_PtrSize * 2) + 16 ; offset of resource record (RR) within the DNS_RECORD structure
   HDLL := DllCall("LoadLibrary", "Str", "Dnsapi.dll", "UPtr")
   CNAME := ""
   Error := 0
   ResultArray := []
   If RegExMatch(AddrOrName, "^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$", IP) {
      RevIP := IP4 . "." . IP3 . "." . IP2 . "." . IP1 . ".IN-ADDR.ARPA"
      If !(Error := DllCall("Dnsapi.dll\DnsQuery_", "Str", RevIP, "Short", 0x0C, "UInt", 0, "Ptr", 0, "PtrP", PDNS, "Ptr", 0)) {
         REC_TYPE := NumGet(PDNS + 0, A_PtrSize * 2, "UShort")
         If (REC_TYPE = 0x0C) { ; DNS_TYPE_PTR
            PDR := PDNS
            While (PDR) {
               Name := StrGet(NumGet(PDR + 0, OffRR, "UPtr"))
               ResultArray.Push(Name)
               PDR := NumGet(PDR + 0, "UPtr")
            }
         }
         DllCall("Dnsapi.dll\DnsRecordListFree", "Ptr", PDNS, "Int", 1) ; DnsFreeRecordList
      }
   }
   Else {
      CNAME := AddrOrName
      Loop {
         If !(Error := DllCall("Dnsapi.dll\DnsQuery_", "Str", CNAME, "Short", 0x01, "UInt", 0, "Ptr", 0, "PtrP", PDNS, "Ptr", 0)) {
            REC_TYPE := NumGet(PDNS + 0, A_PtrSize * 2, "UShort")
            If (REC_TYPE = 0x05) { ; DNS_TYPE_CNAME
               CNAME := StrGet(NumGet(PDNS + OffRR, "UPtr"))
               DllCall("Dnsapi.dll\DnsRecordListFree", "Ptr", PDNS, "Int", 1) ; DnsFreeRecordList
               Continue
            }
            If (REC_TYPE = 0x01) { ; DNS_TYPE_A
               PDR := PDNS
               While (PDR) {
                  Addr := ""
                  Loop, 4
                     Addr .= NumGet(PDR + OffRR + (A_Index - 1), "UChar") . "."
                  ResultArray.Push(RTrim(Addr, "."))
                  PDR := NumGet(PDR + 0, "UPtr")
               }
               DllCall("Dnsapi.dll\DnsRecordListFree", "Ptr", PDNS, "Int", 1) ; DnsFreeRecordList
               Break
            }
         }
         Break
      }
   }
   DllCall("FreeLibrary", "Ptr", HDLL)
   ErrorLevel := Error
   Return ResultArray[1]
}
