# Project

cmake_minimum_required(VERSION 3.21)
project(${SKBUILD_PROJECT_NAME} VERSION ${SKBUILD_PROJECT_VERSION} LANGUAGES C)

# Paths

set(pycowl_project_dir "${CMAKE_CURRENT_LIST_DIR}")
set(pycowl_src_dir "${pycowl_project_dir}/src/cowl")
set(pycowl_native_lib_dir "${pycowl_project_dir}/lib/cowl")

# Packages

find_package(Python COMPONENTS Interpreter Development.Module REQUIRED)
include(UseCython)

# Cython

cython_transpile("${pycowl_src_dir}/_cowl.pyx" OUTPUT_VARIABLE _cowl_c)

# Cowl

if(NOT TARGET cowl)
    add_subdirectory("${pycowl_native_lib_dir}" EXCLUDE_FROM_ALL)
endif()

# Targets

if(COWL_LTO)
    include(CheckIPOSupported)
    check_ipo_supported(RESULT lto_enabled)
else()
    set(lto_enabled OFF)
endif()

python_add_library(_cowl MODULE "${_cowl_c}" WITH_SOABI)
set_target_properties(_cowl PROPERTIES INTERPROCEDURAL_OPTIMIZATION ${lto_enabled})
target_link_libraries(_cowl PUBLIC cowl)

install(TARGETS _cowl DESTINATION cowl)
