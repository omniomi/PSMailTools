$Source = @'
using System;
using System.Text.RegularExpressions;
using System.Collections;
using System.Collections.Generic;

namespace MailTools
{
    namespace Message
    {
        namespace Source
        {
            public class Received
            {
                public string Hop { get; set; }
                public string Delay { get; set; }
                public string From { get; set; }
                public string By { get; set; }
                public string With { get; set; }
                public string Timestamp { get; set; }
            }
        }
    }
}
'@
if (-not ("MailTools.Message.Source.Received" -as [type])) {
    Add-Type -TypeDefinition $Source -Language CSharp -ErrorAction SilentlyContinue
}
