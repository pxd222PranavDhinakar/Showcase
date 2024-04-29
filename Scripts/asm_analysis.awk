#!/usr/bin/awk -f

BEGIN {
    print "Assembly Code Analysis:\n"
}

/^[^;]/ {
    # Remove leading whitespace
    gsub(/^\s+/, "")

    # Extract the instruction and operands
    instruction = $1
    operands = $0
    sub(/^[^\t]+\t*/, "", operands)

    # Analyze the instruction
    if (instruction == ".cfi_startproc") {
        print "Start of the function prologue"
    } else if (instruction == "sub") {
        print "Subtract " operands " from the stack pointer (sp) to allocate stack space"
    } else if (instruction == ".cfi_def_cfa_offset") {
        print "Set the CFA (Canonical Frame Address) offset to " operands
    } else if (instruction == "stp") {
        print "Store a pair of registers " operands " onto the stack"
    } else if (instruction == "add") {
        print "Add " operands " to the destination register"
    } else if (instruction == ".cfi_def_cfa") {
        print "Define the CFA (Canonical Frame Address) register and offset"
    } else if (instruction == ".cfi_offset") {
        print "Set the offset of a register " operands " in the CFA"
    } else if (instruction == "mov") {
        print "Move the value " operands " to the destination register"
    } else if (instruction == "str") {
        print "Store the value from register " operands " to memory"
    } else if (instruction == "adrp") {
        print "Calculate the page address of a symbol " operands " and store it in the destination register"
    } else if (instruction == "add") {
        print "Add the page offset of a symbol " operands " to the destination register"
    } else if (instruction == "bl") {
        print "Branch with link to the function " operands
    } else if (instruction == "ldp") {
        print "Load a pair of registers " operands " from the stack"
    } else if (instruction == "ret") {
        print "Return from the function"
    } else if (instruction == ".loh") {
        print "Linker optimization hint: " operands
    } else if (instruction == ".cfi_endproc") {
        print "End of the function epilogue"
    } else {
        print "Unknown instruction: " $0
    }

    print ""
}

/^;/ {
    print "Comment: " $0 "\n"
}

END {
    print "End of Assembly Code Analysis"
}

/^\s*\.section/ {
    print "Directive: Specify the section for the following code or data: " $0
}

/^\s*\.build_version/, /^\s*\.sdk_version/ {
    print "Directive: Specify build and SDK version information: " $0
}

/^\s*\.globl/ {
    print "Directive: Declare a global symbol: " $0
}

/^\s*\.p2align/ {
    print "Directive: Align the following code or data on a power-of-two boundary: " $0
}

/^\s*[a-zA-Z0-9_]+:/ {
    print "Label: Define a label for addressability: " $0
}

# ... Add more rules for other directives and instructions