# Day 1: IDT Foundation & Structure Setup
## Complete Implementation Guide & Resources

===============================================================================
                            ARCHITECTURAL OVERVIEW
===============================================================================

## 🎯 **Day 1 Objectives**
Today you'll build the foundational structures and basic framework for the x86 Interrupt Descriptor Table (IDT). This forms the core infrastructure that all interrupt and exception handling will build upon.

## 📋 **What You'll Accomplish**
- ✅ Understand x86 IDT architecture at hardware level
- ✅ Define proper IDT data structures following Intel specifications
- ✅ Create IDT initialization framework
- ✅ Build assembly interface for hardware IDT operations
- ✅ Establish interrupt constants and type definitions
- ✅ Set up comprehensive unit testing foundation

===============================================================================
                                TASK BREAKDOWN
===============================================================================

## 🔧 **Task 1.1: IDT Structure Definition (2 hours)**

### **Objective:**
Create the core IDT data structures that match x86 hardware requirements exactly.

### **What You Need to Understand:**

#### **IDT Gate Descriptor Structure (8 bytes)**
```
Bits 63-48: Offset 31:16    (High word of interrupt handler address)
Bits 47:    Present (P)     (1 = valid descriptor, 0 = invalid)
Bits 46-45: DPL            (Descriptor Privilege Level: 0=kernel, 3=user)
Bit  44:    S               (Storage Segment: always 0 for gates)
Bits 43-40: Type           (Gate type: 1110=interrupt, 1111=trap, 0101=task)
Bits 39-32: Reserved       (Must be zero)
Bits 31-16: Selector       (Code segment selector - typically 0x08)
Bits 15-0:  Offset 15:0    (Low word of interrupt handler address)
```

#### **IDT Register Structure (6 bytes)**
```
Bits 47-16: Base Address    (32-bit linear address of IDT table)
Bits 15-0:  Limit          (Size of IDT in bytes minus 1)
```

### **Key Architecture Points:**
- **Alignment**: Structures must be packed (no padding)
- **Size Validation**: Use compile-time assertions
- **Endianness**: x86 is little-endian
- **Memory Layout**: IDT entries are sequential in memory

### **Files to Create:**
- `include/idt_types.h` - Core structure definitions
- `include/idt_constants.h` - Hardware constants and flags

### **Critical Requirements:**
1. **Exact Size Matching**: IDT gate = 8 bytes, IDT register = 6 bytes
2. **Bit Field Accuracy**: Must match Intel specification exactly
3. **Compiler Attributes**: Use `__attribute__((packed))`
4. **Static Assertions**: Verify sizes at compile time

---

## 🔧 **Task 1.2: IDT Table Initialization (3 hours)**

### **Objective:**
Create the IDT table in memory and functions to populate it with gate descriptors.

### **Architecture Design:**

#### **Memory Layout:**
```
IDT Table (4KB aligned recommended):
+0x000: Gate 0  (Divide Error)           [8 bytes]
+0x008: Gate 1  (Debug Exception)        [8 bytes]
+0x010: Gate 2  (NMI)                    [8 bytes]
...
+0x7F8: Gate 255 (User Defined)         [8 bytes]
Total: 256 entries × 8 bytes = 2048 bytes
```

#### **Critical Functions Needed:**
1. **idt_set_gate()** - Populate individual IDT entries
2. **idt_clear_gate()** - Clear/invalidate entries
3. **idt_get_gate()** - Read existing gate configuration
4. **idt_validate_table()** - Verify IDT integrity

### **Memory Management Strategy:**
- **Static Allocation**: IDT table as static array (simple, predictable)
- **Alignment**: 8-byte aligned minimum (some recommend 4KB)
- **Initialization**: Zero-initialize all entries initially
- **Validation**: Bounds checking on all array access

### **Files to Create:**
- `src/idt_table.c` - IDT table management
- `include/idt_table.h` - Public interface

### **Key Implementation Points:**
1. **Thread Safety**: Consider if interrupts can modify IDT during setup
2. **Error Handling**: Proper bounds checking and error codes
3. **Address Splitting**: Correctly split 32-bit addresses into high/low parts
4. **Flag Encoding**: Properly combine type, DPL, and present bits

---

## 🔧 **Task 1.3: Assembly Interface (2 hours)**

### **Objective:**
Create assembly language routines to interface with x86 IDT hardware instructions.

### **Required Assembly Instructions:**

#### **LIDT (Load IDT Register)**
```assembly
lidt [memory_operand]    ; Load 48-bit IDT register from memory
```

#### **SIDT (Store IDT Register)**
```assembly
sidt [memory_operand]    ; Store current IDT register to memory
```

### **Assembly Interface Design:**

#### **Function Signatures (C callable):**
```c
extern void idt_load_register(idt_register_t *idtr);
extern void idt_store_register(idt_register_t *idtr);
extern uint32_t idt_get_current_base(void);
extern uint16_t idt_get_current_limit(void);
```

### **Assembly Implementation Considerations:**
1. **Calling Convention**: Follow System V ABI or cdecl
2. **Register Preservation**: Save/restore caller-saved registers
3. **Stack Management**: Proper function prologue/epilogue
4. **Error Handling**: How to handle instruction faults

### **Files to Create:**
- `src/idt_asm.s` or `src/idt_asm.asm` - Assembly routines
- `include/idt_asm.h` - Assembly function prototypes

### **Testing Strategy:**
- Mock LIDT/SIDT for unit testing (use function pointers)
- Verify parameter passing works correctly
- Test on real hardware vs. emulator differences

---

## 🔧 **Task 1.4: Constants and Definitions (1 hour)**

### **Objective:**
Define all hardware constants, interrupt numbers, and type definitions.

### **Constants Categories:**

#### **Interrupt Vector Numbers:**
```c
// CPU Exceptions (0-31)
#define EXCEPTION_DIVIDE_ERROR      0
#define EXCEPTION_DEBUG             1
#define EXCEPTION_NMI               2
#define EXCEPTION_BREAKPOINT        3
#define EXCEPTION_OVERFLOW          4
#define EXCEPTION_BOUND_RANGE       5
#define EXCEPTION_INVALID_OPCODE    6
#define EXCEPTION_DEVICE_NOT_AVAIL  7
#define EXCEPTION_DOUBLE_FAULT      8
// ... continue to 31

// Hardware IRQs (32-47 typically)
#define IRQ_TIMER                   32
#define IRQ_KEYBOARD                33
#define IRQ_CASCADE                 34
// ... continue mapping

// System Calls (128 typically)
#define SYSCALL_VECTOR              128
```

#### **Gate Types and Flags:**
```c
// Gate Types (Intel Manual Table 6-2)
#define IDT_TYPE_TASK_GATE          0x05
#define IDT_TYPE_INTERRUPT_GATE     0x0E
#define IDT_TYPE_TRAP_GATE          0x0F

// Privilege Levels
#define IDT_DPL_KERNEL              0x00
#define IDT_DPL_USER                0x60

// Present Flag
#define IDT_PRESENT                 0x80
```

### **Files to Create:**
- `include/interrupt_vectors.h` - Interrupt number definitions
- `include/idt_flags.h` - Gate type and flag definitions

===============================================================================
                            ESSENTIAL REFERENCES
===============================================================================

## 📚 **Required Reading**

### **Intel Official Documentation:**
1. **Intel 64 and IA-32 Architectures Software Developer's Manual**
   - Volume 3A: System Programming Guide, Part 1
   - Chapter 6: Interrupt and Exception Handling
   - Section 6.10: Interrupt Descriptor Table (IDT)
   - **Download**: intel.com/developer/articles/technical/intel-sdm

### **Linux Kernel Sources (for reference):**
1. **IDT Implementation:**
   - `arch/x86/include/asm/desc_defs.h` - Descriptor definitions
   - `arch/x86/kernel/idt.c` - IDT management
   - `arch/x86/include/asm/desc.h` - Descriptor manipulation

2. **Exception Handling:**
   - `arch/x86/kernel/traps.c` - Exception handlers
   - `arch/x86/entry/entry_32.S` - Assembly entry points

### **Essential Books:**

#### **"Understanding the Linux Kernel" (3rd Edition)**
- **Authors**: Daniel Bovet, Marco Cesati
- **Chapter 4**: Interrupts and Exceptions
- **Focus**: Linux IDT implementation details
- **Why Important**: Shows production-quality implementation patterns

#### **"Intel Architecture Software Developer's Manual"**
- **Volume 3**: System Programming
- **Chapter 5**: Protection
- **Chapter 6**: Interrupt and Exception Handling
- **Why Important**: Authoritative hardware specification

#### **"Operating System Design and Implementation" (Tanenbaum)**
- **Chapter 2**: Processes and Threads
- **Focus**: Interrupt handling theory
- **Why Important**: Conceptual foundation

#### **"Linux Kernel Development" (Robert Love)**
- **Chapter 7**: Interrupts and Interrupt Handlers
- **Focus**: Modern Linux interrupt subsystem
- **Why Important**: Current best practices

### **Online Resources:**

#### **OSDev Wiki**
- **URL**: wiki.osdev.org/Interrupt_Descriptor_Table
- **Content**: Practical IDT implementation guide
- **Code Examples**: Assembly and C implementations

#### **Intel Developer Zone**
- **URL**: software.intel.com/content/www/us/en/develop/
- **Focus**: x86 architecture deep dives
- **Tools**: Intel Processor Identification Utility

#### **MIT 6.828 Operating System Engineering**
- **URL**: ocw.mit.edu/courses/6-828-operating-system-engineering/
- **Labs**: Practical OS implementation including IDT
- **Code**: Real working examples

===============================================================================
                              UNIT TESTING PLAN
===============================================================================

## 🧪 **Test Categories**

### **Structure Size and Alignment Tests:**
```c
// Test IDT gate descriptor size
assert(sizeof(idt_gate_t) == 8);

// Test IDT register size
assert(sizeof(idt_register_t) == 6);

// Test structure alignment
assert(offsetof(idt_gate_t, offset_low) == 0);
assert(offsetof(idt_gate_t, selector) == 2);
// ... continue for all fields
```

### **Bit Field Layout Tests:**
```c
// Test flag encoding/decoding
idt_gate_t gate = {0};
set_gate_flags(&gate, IDT_TYPE_INTERRUPT | IDT_PRESENT | IDT_DPL_KERNEL);
assert(get_gate_type(&gate) == IDT_TYPE_INTERRUPT);
assert(is_gate_present(&gate) == true);
assert(get_gate_dpl(&gate) == IDT_DPL_KERNEL);
```

### **Address Splitting Tests:**
```c
// Test 32-bit address handling
uint32_t test_addr = 0x12345678;
idt_gate_t gate;
set_gate_handler(&gate, test_addr);
assert(get_gate_handler(&gate) == test_addr);
```

### **Assembly Interface Tests:**
```c
// Mock assembly functions for testing
void mock_lidt(idt_register_t *idtr) { /* record call */ }
void mock_sidt(idt_register_t *idtr) { /* fill test data */ }

// Test IDT loading
idt_register_t test_idtr = {0x1000, 0x80000000};
idt_load_register(&test_idtr);
verify_lidt_called_with(&test_idtr);
```

### **Files to Create:**
- `tests/test_idt_structures.c` - Structure and size tests
- `tests/test_idt_table.c` - Table management tests
- `tests/test_idt_assembly.c` - Assembly interface tests
- `tests/mock_hardware.c` - Hardware mocking utilities

===============================================================================
                            IMPLEMENTATION STRATEGY
===============================================================================

## 🏗️ **Development Approach**

### **Phase 1: Structure Definition (30 minutes)**
1. Start with basic structure definitions
2. Add compile-time size assertions
3. Test structure sizes and alignment
4. Verify bit field layouts work correctly

### **Phase 2: Table Management (90 minutes)**
1. Create static IDT table array
2. Implement idt_set_gate() function
3. Add bounds checking and error handling
4. Test gate setting and retrieval

### **Phase 3: Assembly Interface (60 minutes)**
1. Write LIDT/SIDT wrapper functions
2. Test assembly linkage with C code
3. Create mocking framework for unit tests
4. Verify calling conventions work

### **Phase 4: Constants and Integration (30 minutes)**
1. Define all interrupt vector constants
2. Create flag combination macros
3. Test constant usage in practice
4. Document everything thoroughly

## 🔍 **Common Pitfalls to Avoid**

### **Structure Packing Issues:**
- **Problem**: Compiler adds padding, breaking hardware compatibility
- **Solution**: Always use `__attribute__((packed))` and verify sizes

### **Address Splitting Bugs:**
- **Problem**: Incorrect high/low word calculation
- **Solution**: Use bit shifting and masking carefully

### **Assembly Calling Convention:**
- **Problem**: Stack corruption or wrong parameters
- **Solution**: Follow ABI specification exactly, test thoroughly

### **Privilege Level Encoding:**
- **Problem**: Wrong bit positions for DPL field
- **Solution**: Follow Intel manual bit field diagrams exactly

## 📊 **Success Metrics**

### **Code Quality:**
- [ ] All structures exactly match Intel specifications
- [ ] 100% unit test coverage for all functions
- [ ] No compiler warnings with -Wall -Wextra
- [ ] Static analysis passes (cppcheck, clang-analyzer)

### **Functionality:**
- [ ] IDT table can be created and populated
- [ ] Assembly interface loads IDT correctly
- [ ] All 256 interrupt slots can be configured
- [ ] Error conditions handled gracefully

### **Performance:**
- [ ] IDT operations complete in <1000 cycles
- [ ] Memory usage under 4KB for IDT table
- [ ] No memory leaks or buffer overflows

===============================================================================
                              DEBUGGING GUIDE
===============================================================================

## 🐛 **Debugging Techniques**

### **Hardware-Level Debugging:**
```c
// Read current IDT to verify loading
idt_register_t current_idt;
idt_store_register(&current_idt);
printf("IDT Base: 0x%08x, Limit: 0x%04x\n",
       current_idt.base, current_idt.limit);
```

### **Structure Debugging:**
```c
// Dump IDT gate contents
void dump_idt_gate(int num) {
    idt_gate_t *gate = &idt_table[num];
    printf("Gate %d: Handler=0x%08x, Selector=0x%04x, Flags=0x%02x\n",
           num, get_handler_address(gate), gate->selector, gate->type_attr);
}
```

### **Assembly Debugging:**
- Use GDB with assembly view: `layout asm`
- Set breakpoints on LIDT: `break *0xaddress`
- Examine registers: `info registers`
- Check memory: `x/8bx $esp` (examine stack)

### **Common Debug Scenarios:**
1. **IDT Not Loading**: Check IDTR contents with SIDT
2. **Wrong Gate Size**: Verify structure packing with sizeof()
3. **Assembly Linkage**: Check symbol resolution with nm/objdump
4. **Memory Corruption**: Use valgrind or AddressSanitizer

===============================================================================
                                BUILD SYSTEM
===============================================================================

## 🔨 **Makefile Structure**

```makefile
# Day 1 IDT Implementation Build System

CC = gcc
ASM = nasm
CFLAGS = -Wall -Wextra -std=c11 -g -O0 -fno-stack-protector
ASMFLAGS = -f elf32 -g

# Directories
SRC_DIR = src
INC_DIR = include
TEST_DIR = tests
BUILD_DIR = build

# Source files
C_SOURCES = $(wildcard $(SRC_DIR)/*.c)
ASM_SOURCES = $(wildcard $(SRC_DIR)/*.s)
TEST_SOURCES = $(wildcard $(TEST_DIR)/*.c)

# Object files
C_OBJECTS = $(C_SOURCES:$(SRC_DIR)/%.c=$(BUILD_DIR)/%.o)
ASM_OBJECTS = $(ASM_SOURCES:$(SRC_DIR)/%.s=$(BUILD_DIR)/%.o)
TEST_OBJECTS = $(TEST_SOURCES:$(TEST_DIR)/%.c=$(BUILD_DIR)/%.o)

# Targets
all: idt_day1 run_tests

idt_day1: $(C_OBJECTS) $(ASM_OBJECTS)
	$(CC) $(LDFLAGS) -o $@ $^

run_tests: $(TEST_OBJECTS) $(C_OBJECTS)
	$(CC) $(LDFLAGS) -o $@ $^ -lcriterion
	./$@

# Build rules
$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c
	@mkdir -p $(BUILD_DIR)
	$(CC) $(CFLAGS) -I$(INC_DIR) -c $< -o $@

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.s
	@mkdir -p $(BUILD_DIR)
	$(ASM) $(ASMFLAGS) $< -o $@

$(BUILD_DIR)/%.o: $(TEST_DIR)/%.c
	@mkdir -p $(BUILD_DIR)
	$(CC) $(CFLAGS) -I$(INC_DIR) -c $< -o $@

clean:
	rm -rf $(BUILD_DIR) idt_day1 run_tests

.PHONY: all clean run_tests
```

===============================================================================
                                DELIVERABLES
===============================================================================

## 📦 **Day 1 Completion Checklist**

### **Source Files Created:**
- [ ] `include/idt.h` - Core IDT structure definitions
- [ ] `include/idt_constants.h` - Hardware constants and flags
- [ ] `src/idt_table.c` - IDT table management functions
- [ ] `src/idt_asm.s` - Assembly hardware interface
- [ ] `tests/test_idt_day1.c` - Comprehensive unit tests

### **Functionality Implemented:**
- [ ] IDT gate descriptor structure (8 bytes, packed)
- [ ] IDT register structure (6 bytes, packed)
- [ ] IDT table allocation and initialization
- [ ] Gate setting and retrieval functions
- [ ] Assembly LIDT/SIDT interface
- [ ] All interrupt vector constants defined
- [ ] Complete unit test coverage

### **Quality Assurance:**
- [ ] All tests pass with 100% coverage
- [ ] No compiler warnings or errors
- [ ] Static analysis clean (cppcheck)
- [ ] Memory leak detection clean (valgrind)
- [ ] Code review completed
- [ ] Documentation up to date

### **Integration Ready:**
- [ ] APIs defined for Day 2 interrupt stubs
- [ ] Error handling framework in place
- [ ] Logging/debugging infrastructure ready
- [ ] Build system configured and tested

===============================================================================

🎯 **Ready to Start Day 1?**

You now have everything you need to implement the IDT foundation. Focus on getting the structures exactly right - everything else builds on this foundation. Take your time with the bit field layouts and assembly interface, as these are the most error-prone parts.

**Next Step**: Start with Task 1.1 and create the basic IDT structures. Test them thoroughly before moving on!