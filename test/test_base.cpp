#include "../datas/tchar.hpp"
#include "allocator_hybrid.inl"
#include "endian.inl"
#include "fileinfo.inl"
#include "flags.inl"
#include "float.inl"
#include "matrix44.inl"
#include "supercore.inl"
#include "vector_simd.inl"

#include "bincore.inl"

int main() {
  printer.AddPrinterFunction(UPrintf);

  printline("Compiler info:\n\tLittle Endian: "
            << ES_LITTLE_ENDIAN << "\n\tX64: " << ES_X64
            << "\n\tClass padding optimalization: " << ES_REUSE_PADDING);

  printerror("I am error and I'm red.");
  printwarning("I am warning and I'm yellow.");
  SetConsoleTextColor(127, 127, 255);
  printline("I'm blue, da ri di danu da.") RestoreConsoleTextColor();

  TEST_CASES(int testResult, TEST_FUNC(test_alloc_hybrid),
             TEST_FUNC(test_fileinfo), TEST_FUNC(test_endian),
             TEST_FUNC(test_flags_00), TEST_FUNC(test_flags_01),
             TEST_FUNC(test_bincore_00), TEST_FUNC(test_bincore_01),
             TEST_FUNC(test_bincore_02), TEST_FUNC(test_matrix44_00),
             TEST_FUNC(test_matrix44_01), TEST_FUNC(test_matrix44_02),
             TEST_FUNC(test_matrix44_03), TEST_FUNC(test_float_00),
             TEST_FUNC(test_float_01), TEST_FUNC(test_vector_simd_00),
             TEST_FUNC(test_vector_simd_01), TEST_FUNC(test_vector_simd_02),
             TEST_FUNC(test_vector_simd_03), TEST_FUNC(test_vector_simd_10),
             TEST_FUNC(test_vector_simd_11), TEST_FUNC(test_vector_simd_12),
             TEST_FUNC(test_supercore_00));

  return testResult;
}