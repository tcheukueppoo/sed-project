# A JSON Validator by Kueppo Tcheukam (tcheukueppo@yandex.com)

# Buffer the whole lines into the pattern space

:buffer {
   $b parser
   N
   b buffer
}

# Check for valid JSON signature in the hold space; die otherwise
:sig_check {
   x
   s/{$/{k/
   x
   t next
   x
   s/{k:$/{k:v/
   x
   t next
   x
   s/\[$/\[v/
   x
   t next
   x
   s/^$/v/
   x
   t next
   b syn_error
}

:parser :next {

   s/^[[:space:]]*//
   s/\
//
   s/^[[:space:]]*//

   /^$/b end

   # Literals

   ## String
   /^"/{
      s/"\(\\.\|[^"\\]\)*"//
      t sig_check
      b str_error
   }

   ## Decimal
   /^\([-+]?\) [0-9]/ {
      s/([+-]?\ *([0-9]+(\.[0-9]*)?|\.[0-9]+)([eE]([+-]?[0-9]+))?)//
      t sig_check
      b num_error
   }

   ## Binary
   /^0b/ {
      s/0b[01]\+//
      t sig_check
      b num_error
   }

   ## Hexadecimal
   /^0x/ {
      s/0x[0123456789ABCDEFabcdef]\+//
      t sig_check
      b num_error
   }

   ## Octal
   /^0/ {
      s/0[0-7]\+//
      t sig_check
      b num_error
   }

   # Parse Complex constructs

   ## Arrays
   /^\[/ {
      s/\[//
      x
      s/.*/&\[/
      x
      b next
   }
   /^\]/ {
      s/\]//
      x
      s/\[\(\(v,\)\+v\|v\)\?$/v/
      x
      t next
      b syn_error
   }
   /^,/ {
      s/,//
      x
      s/\(\[\(\(v,\)\+v\|v\)\|{\(\(k:v,\)\+\(k:v\)\|k:v\)\)$/\1,/
      x
      t next
      b syn_error
   }


   ## Maps
   /^{/ {
      s/{//
      x
      s/.*/&\{/
      x
      b next
   }
   /^:/ {
      s/://
      x
      s/\({\(k:v,\)*k\)/&:/
      x
      t next
      b syn_error
   }
   /}/ {
      s/}//
      x
      s/{\(\(k:v,\)\+\(k:v\)|k:v\)\?/v/
      x
      t next
      b syn_error
   }

}

:num_error {
   s/.*/Couldn't parse number literal./q
   q
}

:str_error {
   s/.*/Couldn't parse string literal./p
   q
}

:syn_error {
   s/.*/Syntax error./p
   q
}

:end {
   x
   /^v$/ {
      s/.*/OK/p
      q
   }

   b syn_error
}
