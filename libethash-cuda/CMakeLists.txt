find_package(CUDA REQUIRED)

set(CUDA_NVCC_FLAGS ${CUDA_NVCC_FLAGS};--ptxas-options=-v;-use_fast_math)

if(APPLE)
    if(CMAKE_SYSTEM_VERSION MATCHES "19.6.0")
        message(STATUS "[Apple ] Found macOS 10.15.7 Catalina (uname -r: ${CMAKE_SYSTEM_VERSION})")
        set(MACOSX_DEPLOYMENT_TARGET 10.15)
        set(CMAKE_OSX_DEPLOYMENT_TARGET 10.15)
        set(CMAKE_OSX_ARCHITECTURES x86_64)
    elseif(CMAKE_SYSTEM_VERSION MATCHES "20.6.0")
        message(STATUS "[Apple ] Found macOS 11.6.2 Big Sur (uname -r: ${CMAKE_SYSTEM_VERSION})")
        set(MACOSX_DEPLOYMENT_TARGET 11.3)
        set(CMAKE_OSX_DEPLOYMENT_TARGET 11.3)
        #
        # Cross-compile doesn't work right now. 
        # Because of libraries that haven't updated their
        # CMake settings for Universal support: jsoncpp ethash CLI11
        #set(CMAKE_OSX_ARCHITECTURES arm64;x86_64)
        #
        # Use this until packgaes have added support
        set(CMAKE_OSX_ARCHITECTURES ${CMAKE_SYSTEM_PROCESSOR})
    elseif(CMAKE_SYSTEM_VERSION MATCHES "21.2.0")
        message(STATUS "[Apple ] Found macOS 12.1 Monterey (uname -r: ${CMAKE_SYSTEM_VERSION})")
        set(MACOSX_DEPLOYMENT_TARGET 12.1)
        set(CMAKE_OSX_DEPLOYMENT_TARGET 12.1)
        #
        # Cross-compile doesn't work right now. 
        # Because of libraries that haven't updated their
        # CMake settings for Universal support: jsoncpp ethash
        #set(CMAKE_OSX_ARCHITECTURES arm64;x86_64)
        #
        # Use this until packgaes have added support
        set(CMAKE_OSX_ARCHITECTURES ${CMAKE_SYSTEM_PROCESSOR})
    else()
        message(STATUS "[Apple ] Found macOS *** (uname -r: ${CMAKE_SYSTEM_VERSION})")
        set(CMAKE_OSX_ARCHITECTURES ${CMAKE_SYSTEM_PROCESSOR})
    endif()
endif()

if (NOT MSVC)
	list(APPEND CUDA_NVCC_FLAGS "--disable-warnings")
endif()

list(APPEND CUDA_NVCC_FLAGS_RELEASE -O3)
list(APPEND CUDA_NVCC_FLAGS_DEBUG -G)

if(COMPUTE AND (COMPUTE GREATER 0))
	list(APPEND CUDA_NVCC_FLAGS "-gencode arch=compute_${COMPUTE},code=sm_${COMPUTE}")
else()
	if (CUDA_VERSION VERSION_LESS 11.0)
		list(APPEND CUDA_NVCC_FLAGS "-gencode arch=compute_30,code=sm_30")
	endif()
	list(APPEND CUDA_NVCC_FLAGS "-gencode arch=compute_35,code=sm_35")
	list(APPEND CUDA_NVCC_FLAGS "-gencode arch=compute_50,code=sm_50")
	list(APPEND CUDA_NVCC_FLAGS "-gencode arch=compute_52,code=sm_52")
	list(APPEND CUDA_NVCC_FLAGS "-gencode arch=compute_53,code=sm_53")
	list(APPEND CUDA_NVCC_FLAGS "-gencode arch=compute_60,code=sm_60")
	list(APPEND CUDA_NVCC_FLAGS "-gencode arch=compute_61,code=sm_61")
	list(APPEND CUDA_NVCC_FLAGS "-gencode arch=compute_62,code=sm_62")
	if(NOT CUDA_VERSION VERSION_LESS 9.0)
		list(APPEND CUDA_NVCC_FLAGS "-gencode arch=compute_70,code=sm_70")
	endif()
	if(NOT CUDA_VERSION VERSION_LESS 10.0)
		list(APPEND CUDA_NVCC_FLAGS "-gencode arch=compute_75,code=sm_75")
	endif()
	if(NOT CUDA_VERSION VERSION_LESS 11.0)
		# NVIDIA A100 and NVIDIA DGX-A100
		list(APPEND CUDA_NVCC_FLAGS "-gencode arch=compute_80,code=sm_80")
	endif()
	if(NOT CUDA_VERSION VERSION_LESS 11.1)
		# Tesla GA10x cards, RTX Ampere – RTX 3080/3090, RTX A6000, RTX A40
		list(APPEND CUDA_NVCC_FLAGS "-gencode arch=compute_86,code=sm_86")
	endif()
endif()

file(GLOB sources "*.cpp" "*.cu")
file(GLOB headers "*.h" "*.cuh")

cuda_add_library(ethash-cuda STATIC ${sources} ${headers})
target_link_libraries(ethash-cuda ethcore ethash::ethash Boost::thread)
target_include_directories(ethash-cuda PUBLIC ${CUDA_INCLUDE_DIRS})
target_include_directories(ethash-cuda PRIVATE .. ${CMAKE_CURRENT_BINARY_DIR})
