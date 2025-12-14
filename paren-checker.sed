:next_input
# Clean the expression by removing word tokens
s/[^)(]*//g

# The Stack held in the hold space, the parser uses it to track the flow
s/.*/&|/

# Pick the first parenthese, *hold* the rest and go parse
h
s/^\(.\).*/\1/
b parser

# Tokenizer
:next_token
   g
   s/^.\(.*|.*\)$/\1/

   /^|$/b success
   /^|./b failed
   /^.|$/b failed

   h
   s/^\(.\).*|.*$/\1/
   b parser

# Parser
:parser
   /)/{
      x
      s/\(|.*\)($/\1/
      x
      b next_token
   }

   /(/{
      x
      s/.*/&\(/
      x
      b next_token
   }

:failed
   s/.*/ERR/p
   n
   b next_input

:success
   s/.*/OK/p
   n
   b next_input
