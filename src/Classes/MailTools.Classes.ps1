$Source = @'
using System;
using System.Collections;
using System.Collections.Generic;

namespace MailTools
{
    public class Test
    {

    }
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
                        All = value.Substring(value.LastIndexOf(' ') + 1);
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
if (-not ("MailTools.Security.Test" -as [type])) {
    Add-Type -TypeDefinition $Source -Language CSharp -ErrorAction SilentlyContinue
}