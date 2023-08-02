function(context_version VAR)
  file(GLOB_RECURSE CTX_FILES "${CMAKE_SOURCE_DIR}/*/app_context.hpp")
  set(LAST_LEN 0xffffff)

  foreach(CTX_FILE ${CTX_FILES})
    string(LENGTH ${CTX_FILE} THIS_LEN)
    if(${THIS_LEN} LESS ${LAST_LEN})
      set(LAST_LEN ${THIS_LEN})
      set(CTX_REGX "CONTEXT_VERSION = ([0-9]+);")
      file(STRINGS ${CTX_FILE} CTX_VAR REGEX ${CTX_REGX})
      string(REGEX MATCH ${CTX_REGX} CTX_VERSION ${CTX_VAR})
      set(${VAR} ${CMAKE_MATCH_1} PARENT_SCOPE)
    endif()
  endforeach()
endfunction()

find_package(Git REQUIRED)

function(toolset_version)
  if(NOT SK_VERSION_MINOR)
    context_version(SK_VERSION_MINOR)
    set(SK_VERSION_MINOR ${SK_VERSION_MINOR} CACHE STRING "")
  endif()

  execute_process(COMMAND ${GIT_EXECUTABLE} describe --tags --abbrev=0 --match=v[0-9]* OUTPUT_VARIABLE LAST_TAG)
  string(STRIP "${LAST_TAG}" LAST_TAG)
  set(TAG_RANGE "${LAST_TAG}..")

  if(NOT LAST_TAG)
    set(LAST_TAG "v0.0.0")
    set(TAG_RANGE "HEAD")
  endif()

  execute_process(COMMAND ${GIT_EXECUTABLE} rev-list "${TAG_RANGE}" --count OUTPUT_VARIABLE NUM_COMMITS)
  string(REGEX MATCH "^v([0-9]+).[0-9]+.?([0-9]+)?" GIT_VERSION ${LAST_TAG})
  math(EXPR PROJECT_VERSION_PATCH_ ${CMAKE_MATCH_2}+${NUM_COMMITS})
  set(PROJECT_VERSION_ "${CMAKE_MATCH_1}.${SK_VERSION_MINOR}.${PROJECT_VERSION_PATCH_}")

  set(PROJECT_VERSION_MAJOR ${CMAKE_MATCH_1} PARENT_SCOPE)
  set(PROJECT_VERSION_MINOR ${SK_VERSION_MINOR} PARENT_SCOPE)
  set(PROJECT_VERSION_PATCH ${PROJECT_VERSION_PATCH_} PARENT_SCOPE)
  set(PROJECT_VERSION "${PROJECT_VERSION_}" PARENT_SCOPE)
  file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/version "${PROJECT_VERSION_}")

  message("-- ${PROJECT_NAME} version: ${PROJECT_VERSION_}")
endfunction()

function(module_version TARGET MAJOR_VERSION)
  get_target_property(TARGET_SOURCES ${TARGET} SOURCES)
  file(GLOB_RECURSE PROJECT_SOURCES RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}" "${CMAKE_CURRENT_SOURCE_DIR}/*")
  set(VALID_SOURCES)

  foreach(source ${TARGET_SOURCES})
    foreach(psource ${PROJECT_SOURCES})
      if(${psource} STREQUAL ${source})
        list(APPEND VALID_SOURCES ${source})
      endif()
    endforeach()
  endforeach()

  execute_process(
    COMMAND ${GIT_EXECUTABLE} rev-list HEAD --count -- ${VALID_SOURCES}
    OUTPUT_VARIABLE NUM_COMMITS
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})

  if(NOT SK_VERSION_MINOR)
    context_version(SK_VERSION_MINOR)
    set(SK_VERSION_MINOR ${SK_VERSION_MINOR} CACHE STRING "")
  endif()

  string(STRIP "${NUM_COMMITS}" NUM_COMMITS)
  set(PROJECT_VERSION_ "${MAJOR_VERSION}.${SK_VERSION_MINOR}.${NUM_COMMITS}")

  set(PROJECT_VERSION_MAJOR ${MAJOR_VERSION} PARENT_SCOPE)
  set(PROJECT_VERSION_MINOR ${SK_VERSION_MINOR} PARENT_SCOPE)
  set(PROJECT_VERSION_PATCH ${NUM_COMMITS} PARENT_SCOPE)
  set(PROJECT_VERSION "${PROJECT_VERSION_}" PARENT_SCOPE)

  message("-- ${PROJECT_NAME} version: ${PROJECT_VERSION_}")
endfunction()
