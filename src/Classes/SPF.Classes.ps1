$Source = @'
using System;
using System.Text.RegularExpressions;
using System.Collections;
using System.Collections.Generic;

namespace MailTools
{
    namespace Security
    {
        namespace SPF
        {
            public class SPFRecord
            {
                public string Name { get; set; }
                private string _Value;
                public string All;
                public string Value
                {
                    get { return _Value; }
                    set
                    {
                        _Value = value;

                        string pattern = "(?:-|\\+|~|\\?)all";
                        Match match = Regex.Match(value, pattern);
                        All = match.Value;
                    }
                }
            }

            public class Recursive : SPFRecord
            {
                public int Level { get; set; }
            }

            public class Validation_Basic
            {
                public string Name { get; set; }
                private string _Value;
                public bool RecordFound { get; set; }
                public bool FormatIsValid { get; set; }
                public bool ValidLength
                {
                    get
                    {
                        if (_Value.Length > 255)
                        {
                            return false;
                        }
                        else
                        {
                            return true;
                        }
                    }
                }
                public string Value
                {
                    get
                    {
                        return _Value;
                    }
                    set
                    {
                        _Value = value;
                    }
                }
            }
        }
    }
}
'@
if (-not ("MailTools.Security.SPF.SPFRecord" -as [type])) {
    Add-Type -TypeDefinition $Source -Language CSharp -ErrorAction SilentlyContinue
}