CON

  _clkmode        = xtal1 + pll16x              'Use crystal * 16
  _xinfreq        = 5_000_000                   '5MHz * 16 = 80 MHz

  ' Set pins and Baud rate for XBee comms
  XB_Rx           = 7                 ' XBee DOUT
  XB_Tx           = 6                 ' XBee Din
  XB_Baud         = 9600
  HTTPPort        = $1F90           ' http port 8080 in hex for xbee

  ' Set pins and baud rate for PC comms
  PC_Rx     = 31
  PC_Tx     = 30
  PC_Baud   = 115_200

  ' line
  CR              = $0D
  LF              = $0A


DAT
' value to customise to your camera
   httpHost   byte "192.168.122.1:8080",CR,LF,0 ' change to your Sony IP Address
   SSID       byte "DIRECT-XQC2:DSC-HX60V",0    'SSID provided by your camera
   PWD        byte "GCSkaTun",0                 'PWD from your camera

VAR
  long stack[50]                ' stack space for second cog

OBJ

  PC            : "FullDuplexSerial"
  XB            : "FullDuplexSerial"           'XBee communication methods

PUB Start

  Init

  HttpPrint (@json_GetVersion)
  HttpPost (@json_GetVersion)
  waitcnt(clkfreq  + cnt)

  HttpPrint (@json_startRecMode)
  HttpPost (@json_startRecMode)
  waitcnt(clkfreq * 3 + cnt)     'pause 3 s

  HttpPrint (@json_actTakePicture)
  HttpPost (@json_actTakePicture)
  waitcnt(clkfreq * 5 + cnt)     'pause 3 s

  HttpPrint (@json_stopRecMode)
  HttpPost (@json_stopRecMode)


Pub HttpPrint(strAddr)

  PC.str(string(CR,LF,CR,LF,"-----> Request sent"))
  PC.str(string(CR,LF,"POST /sony/camera HTTP/1.1",CR,LF,"Host: "))
  PC.str(@httpHost)
  PC.str(string("Accept: */*",CR,LF,"Content-Type: application/json",CR,LF))
  PC.str(string("Content-Length: "))
  PC.dec(strsize(strAddr)-8)
  PC.str(strAddr)
  PC.str(string(CR,LF,CR,LF,"<----- Answer received",CR,LF))

Pub HttpPost(strAddr)

  XB.str(string("POST /sony/camera HTTP/1.1",CR,LF,"Host: "))
  XB.str(@httpHost)
  XB.str(string("Accept: */*",CR,LF,"Content-Type: application/json",CR,LF))
  XB.str(string("Content-Length: "))
  XB.dec(strsize(strAddr)-8)
  XB.str(strAddr)

PUB Init

  PC.start(PC_Rx, PC_Tx, 0, PC_Baud) ' Initialize comms for PC
  XB.start(XB_Rx, XB_Tx, 0, XB_Baud) ' Initialize comms for XBee

  cognew(XB_to_PC,@stack)       ' Start cog for XBee--> PC comms
  PC.rxFlush                    ' Empty buffer for data from PC

Pub XB_to_PC

  XB.rxFlush                    ' Empty buffer for data from XB
  repeat
    PC.tx(XB.rx)                ' Accept data from XBee and send to PC

DAT

  json_GetVersion
                 byte CR,LF,CR,LF
                 byte "{"
                 byte 34,"version",34,":",34,"1.0",34,","
                 byte 34,"id",34,":1,"
                 byte 34,"method",34,":",34,"getVersions",34,","
                 byte 34,"params",34,":[]"
                 byte "}",CR,LF,CR,LF,0

  json_startRecMode
                 byte CR,LF,CR,LF
                 byte "{"
                 byte 34,"version",34,":",34,"1.0",34,","
                 byte 34,"id",34,":1,"
                 byte 34,"method",34,":",34,"startRecMode",34,","
                 byte 34,"params",34,":[]"
                 byte "}",CR,LF,CR,LF,0

  json_actTakePicture
                 byte CR,LF,CR,LF
                 byte "{"
                 byte 34,"version",34,":",34,"1.0",34,","
                 byte 34,"id",34,":1,"
                 byte 34,"method",34,":",34,"actTakePicture",34,","
                 byte 34,"params",34,":[]"
                 byte "}",CR,LF,CR,LF,0

  json_stopRecMode
                 byte CR,LF,CR,LF
                 byte "{"
                 byte 34,"version",34,":",34,"1.0",34,","
                 byte 34,"id",34,":1,"
                 byte 34,"method",34,":",34,"stopRecMode",34,","
                 byte 34,"params",34,":[]"
                 byte "}",CR,LF,CR,LF,0


{{

┌──────────────────────────────────────────────────────────────────────────────────────┐
│                           TERMS OF USE: MIT License                                  │
├──────────────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy of this  │
│software and associated documentation files (the "Software"), to deal in the Software │
│without restriction, including without limitation the rights to use, copy, modify,    │
│merge, publish, distribute, sublicense, and/or sell copies of the Software, and to    │
│permit persons to whom the Software is furnished to do so, subject to the following   │
│conditions:                                                                           │                                            │
│                                                                                      │                                               │
│The above copyright notice and this permission notice shall be included in all copies │
│or substantial portions of the Software.                                              │
│                                                                                      │                                                │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,   │
│INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A         │
│PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT    │
│HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION     │
│OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE        │
│SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                                │
└──────────────────────────────────────────────────────────────────────────────────────┘
}}
