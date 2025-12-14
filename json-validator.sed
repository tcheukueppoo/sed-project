# A JSON Validator by Kueppo Tcheukam (tcheukueppo@yandex.com)

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

:next {
   ${
      x
      //
      
   }

   s/^[[:space:]]*//

   # Literals

   ## String
   /^"/{
      s/"\(\\.\|[^"\\]\)*"//
      t sig_check
      b str_error
   }

   ## Decimal
   /^([-+]?) [0-9]/ {
      s/([+-]?\ *(\d+(\.[0-9]*)?|\.[0-9]+)([eE]([+-]?[0-9]+))?)//
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
      s/0x[0123456789ABCEFabcdef]\+//
      t sig_check
      b num_error
   }

   ## Octal
   /^0/ {
      s/0x[0-7]\+//
      t sig_check
      b num_error
   }

   # Complex constructs

   ## Arrays
   /^[/ {
      x
      s/.*/&\[/
      x
      b next
   }
   /^]/ {
      x
      s/[\(v,\)*v?$/v/
      x
      t next
      b syn_error
   }
   /^,/ {
      x
      s/\(\[v|\{k:v\+\)$/\1,/
      x
      t next
      b syn_error
   }


   ## Maps
   /^{/ {
      x
      s/.*/&\{/
      x
      b next
   }
   /^:/ {
      x
      s/\({k\)/&:/
      x
      t next
      b syn_error
   }
   /}/ {
      x
      s/\({\(k:v,\)*\(k:v\)?\)/v/
      x
      t next
      b syn_error
   }

}

:num_error {

}

:str_error {
}

:syn_error {
   s//Syntax error line/p
}
