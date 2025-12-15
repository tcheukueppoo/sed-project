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
   s/{\(\(k:v,\)*\)$/{\1k/
   x
   t next
   x
   s/{\(\(k:v,\)*\)k:$/{\1k:v/
   x
   t next
   x
   s/\[\(\(v,\)*\)$/\[\1v/
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
   /^\([-+]\?\)\ *[0-9]/ {
      s/\([+-]\?\ *\([0-9]\+\(\.[0-9]*\)\?\|\.[0-9]\+\)\([eE]\([+-]\?[0-9]\+\)\)\?\)//
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

   # Parse Complex data structure constructs

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
      s/v$/k/
      s/\({\(k:v,\)*k\)$/&:/
      x
      t next
      b syn_error
   }
   /^}/ {
      s/}//
      x
      s/{\(\(k:v,\)\+\(k:v\)\|k:v\)\?$/v/
      x
      t next
      b syn_error
   }

   b syn_error
}

:num_error {
   s/\(.\{,40\}\).*/Couldn't parse number literal before --> "\1"/p
   q
}

:str_error {
   s/\(.\{,40\}\).*/Couldn't parse string literal before --> "\1"/p
   q
}

:syn_error {
   x
   p
   s/\(.\{,40\}\).*/Syntax error before --> "\1"/p
   q
}

:end {
   x
   /^v$/ {
      s/.*/OK/p
      q
   }

   x
   b syn_error
}
