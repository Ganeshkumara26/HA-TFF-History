set parts [get_parts]
set fp [open "available_parts.txt" w]
puts $fp $parts
close $fp
