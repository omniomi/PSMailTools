$Source = @'
using System;
using System.Text.RegularExpressions;
using System.Collections;
using System.Collections.Generic;

namespace MailTools
{
    namespace Security
    {
        namespace DMARC
        {
            public class DMARCRecord
            {
                public string Name { get; set; }
                public string Path { get; set; }
                private string _Value;
                public int? pct;
                public string ruf;
                public string rua;
                public string p;
                public string sp;
                public string adkim;
                public string aspf;
                public string Value
                {
                    get { return _Value; }
                    set
                    {
                        _Value = value;

                        // pct
                        Regex pctExp = new Regex(@"pct=(?<pctValue>[0-9]{1,3})");
                        var pctResults = pctExp.Match(value.ToLower());
                        if (!String.IsNullOrEmpty(pctResults.Groups["pctValue"].Value))
                        {
                            pct = Convert.ToInt32(pctResults.Groups["pctValue"].Value);
                        }

                        // ruf
                        Regex rufExp = new Regex(@"ruf=mailto:(?<rufValue>[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,64})");
                        var rufResults = rufExp.Match(value.ToLower());
                        if (!String.IsNullOrEmpty(rufResults.Groups["rufValue"].Value))
                        {
                            ruf = rufResults.Groups["rufValue"].Value;
                        }

                        // rua
                        Regex ruaExp = new Regex(@"rua=mailto:(?<ruaValue>[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,64})");
                        var ruaResults = ruaExp.Match(value.ToLower());
                        if (!String.IsNullOrEmpty(ruaResults.Groups["ruaValue"].Value))
                        {
                            rua = ruaResults.Groups["ruaValue"].Value;
                        }

                        // policy
                        Regex pExp = new Regex(@"p=(?<pValue>[A-Za-z]+)");
                        var pResults = pExp.Match(value.ToLower());
                        if (!String.IsNullOrEmpty(pResults.Groups["pValue"].Value))
                        {
                            p = pResults.Groups["pValue"].Value;
                        }

                        // sp
                        Regex spExp = new Regex(@"sp=(?<spValue>[A-Za-z]+)");
                        var spResults = spExp.Match(value.ToLower());
                        if (!String.IsNullOrEmpty(spResults.Groups["spValue"].Value))
                        {
                            sp = spResults.Groups["spValue"].Value;
                        }

                        // adkim
                        Regex adkimExp = new Regex(@"adkim=(?<adkimValue>[A-Za-z]+)");
                        var adkimResults = adkimExp.Match(value.ToLower());
                        if (!String.IsNullOrEmpty(adkimResults.Groups["adkimValue"].Value))
                        {
                            adkim = adkimResults.Groups["adkimValue"].Value;
                        }

                        // aspf
                        Regex aspfExp = new Regex(@"aspf=(?<spValue>[A-Za-z]+)");
                        var aspfResults = aspfExp.Match(value.ToLower());
                        if (!String.IsNullOrEmpty(aspfResults.Groups["aspfValue"].Value))
                        {
                            aspf = aspfResults.Groups["aspfValue"].Value;
                        }
                    }
                }
            }

            public class Validation_Basic
            {
                public string Name { get; set; }
                public bool RecordFound { get; set; }
                public bool FormatIsValid { get; set; }
                public string Value { get; set; }
            }
        }
    }
}
'@
if (-not ("MailTools.Security.DMARC.DMARCRecord" -as [type])) {
    Add-Type -TypeDefinition $Source -Language CSharp -ErrorAction SilentlyContinue
}