# A JSON Validator by Kueppo Tcheukam (tcheukueppo@yandex.com)

# Buffer the whole lines into the pattern space

:buffer {
   $b parser
   N
   b buffer
}

# Check for valid JSON signature in the hold space; die otherwise
:check_and_push {
   x
   s/{\(\(v:v,\)*\)$/{\1v/
   p
   x
   t next
   x
   s/{\(\(v:v,\)*\)v:$/{\1v:v/
   p
   x
   t next
   x
   s/\[\(\(v,\)*\)$/\[\1v/
   p
   x
   t next
   x
   s/^$/v/
   p
   x
   t next
   b syn_error
}

:parser :next {

   s/^[[:space:]]\+//
   t next

   s/^\
//
   t next

   s/^[[:space:]]\+//
   t next

   /^$/b end

   # Literals

   ## Null
   /^null/ {
      s/^null//
      t check_and_push
   }

   ## Boolean
   /^\(false\|true\)/ {
      s/false\|true//
      t check_and_push
   }

   ## String
   /^"/{
      s/"\(\\.\|[^"\\]\)*"//
      t check_and_push
   }

   ## Decimal
   /^\([-+]\?\)\ *[0-9]/ {
      s/\([+-]\?\ *\([0-9]\+\(\.[0-9]*\)\?\|\.[0-9]\+\)\([eE]\([+-]\?[0-9]\+\)\)\?\)//
      t check_and_push
   }

   ## Binary
   /^0b/ {
      s/0b[01]\+//
      t check_and_push
   }

   ## Hexadecimal
   /^0x/ {
      s/0x[0123456789ABCDEFabcdef]\+//
      t check_and_push
   }

   ## Octal
   /^0/ {
      s/0[0-7]\+//
      t check_and_push
   }

   # Parse Complex data structure constructs

   ## Arrays
   /^\[/ {
      s/\[//
      x
      s/.*/&\[/
      p
      x
      b next
   }
   /^\]/ {
      s/\]//
      x
      s/\[\(\(v,\)\+v\|v\)\?$/v/
      p
      x
      t next
      b syn_error
   }
   /^,/ {
      s/,//
      x
      s/\(\[\(\(v,\)\+v\|v\)\|{\(v:v\|\(v:v,\)\+\(v:v\)\)\)$/\1,/
      p
      x
      t next
      b syn_error
   }

   ## Maps
   /^{/ {
      s/^{//
      x
      s/.*/&\{/
      p
      x
      b next
   }
   /^:/ {
      s/://
      x
      s/\({\(v:v,\)*v\)$/&:/
      p
      x
      t next
      b syn_error
   }
   /^}/ {
      s/}//
      x
      s/{\(\(v:v,\)\+\(v:v\)\|v:v\)\?$/v/
      p
      x
      t next
      b syn_error
   }

   b syn_error
}

:syn_error {
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
