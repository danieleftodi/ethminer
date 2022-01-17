hunter_config(CURL VERSION ${HUNTER_CURL_VERSION} CMAKE_ARGS HTTP_ONLY=ON CMAKE_USE_OPENSSL=OFF CMAKE_USE_LIBSSH2=OFF CURL_CA_PATH=none)

if(APPLE)
    message(STATUS "[hunter] CMAKE_SYSTEM_NAME: ${CMAKE_SYSTEM_NAME}")
    message(STATUS "[hunter] CMAKE_OSX_SYSROOT: ${CMAKE_OSX_SYSROOT}")
    message(STATUS "[hunter] MACOSX_DEPLOYMENT_TARGET: ${MACOSX_DEPLOYMENT_TARGET}")
    message(STATUS "[hunter] CMAKE_OSX_DEPLOYMENT_TARGET: ${CMAKE_OSX_DEPLOYMENT_TARGET}")
    message(STATUS "[hunter] CMAKE_OSX_ARCHITECTURES ${CMAKE_OSX_ARCHITECTURES}")
    message(STATUS "[hunter] CMAKE_SYSTEM_PROCESSOR ${CMAKE_SYSTEM_PROCESSOR}")    
    if(CMAKE_SYSTEM_VERSION MATCHES "19.6.0")
        message(STATUS "[hunter] Found macOS 10.15.7 Catalina (uname -r: ${CMAKE_SYSTEM_VERSION})")
        hunter_config(Boost VERSION ${HUNTER_Boost_VERSION})
        hunter_config(''
            OpenSSL
            #URL "https://www.openssl.org/source/openssl-1.1.1j.tar.gz"
            #SHA1 "04c340b086828eecff9df06dceff196790bb9268"
            URL "https://www.openssl.org/source/openssl-1.1.1m.tar.gz"
            SHA1 "39d424c4411e45f1570073d7a71b1830b96007ca"
            CMAKE_ARGS CMAKE_C_FLAGS="-v" CMAKE_EXE_LINKER_FLAGS="-v" XCODE_ATTRIBUTE_ONLY_ACTIVE_ARCH=YES CMAKE_CROSSCOMPILING=NO CMAKE_SYSTEM_NAME=Darwin CMAKE_OSX_SYSROOT=macosx10.15 MACOSX_DEPLOYMENT_TARGET=10.15 CMAKE_OSX_DEPLOYMENT_TARGET=10.15 configure_architectures=${CMAKE_SYSTEM_PROCESSOR}
        )
    elseif(CMAKE_SYSTEM_VERSION MATCHES "20.6.0")
        message(STATUS "[hunter] Found macOS 11.6.2 Big Sur (uname -r: ${CMAKE_SYSTEM_VERSION})")
        hunter_config(
            Boost 
            VERSION ${HUNTER_Boost_VERSION}
            CMAKE_ARGS NOTEQUAL=arm64;x86_64
            )
        hunter_config(
            OpenSSL
            #URL "https://www.openssl.org/source/openssl-1.1.1j.tar.gz"
            #SHA1 "04c340b086828eecff9df06dceff196790bb9268"
            URL "https://www.openssl.org/source/openssl-1.1.1m.tar.gz"
            SHA1 "39d424c4411e45f1570073d7a71b1830b96007ca"
            # it is not nessesary to explicitly specify the system arch. 
            # since OpenSSL has checks in place to look up what is availble
            #
            # IMHO: It's better to allow OpenSSL to-do the check it self, 
            # since on macOS it opens up the posibility to compile a 'Universal Binary' 
            # for both Apple M1 Silicon (arm64) & Intel X86_64 when we set the
            # varibale: CMAKE_OSX_ARCHITECTURES
            # 
            # Though if for some reason anyone wants to explcitly specify the system arch,
            # uncomment the following line:
            #CMAKE_ARGS CMAKE_C_FLAGS="-v" CMAKE_EXE_LINKER_FLAGS="-v" XCODE_ATTRIBUTE_ONLY_ACTIVE_ARCH=YES CMAKE_CROSSCOMPILING=NO CMAKE_SYSTEM_NAME=Darwin CMAKE_OSX_SYSROOT=macosx11.3 MACOSX_DEPLOYMENT_TARGET=11.3 CMAKE_OSX_DEPLOYMENT_TARGET=11.3 configure_architectures=${CMAKE_SYSTEM_PROCESSOR}
            # and comment out this line:
            CMAKE_ARGS CMAKE_C_FLAGS="-v" CMAKE_EXE_LINKER_FLAGS="-v" XCODE_ATTRIBUTE_ONLY_ACTIVE_ARCH=NO CMAKE_CROSSCOMPILING=YES CMAKE_SYSTEM_NAME=Darwin CMAKE_OSX_SYSROOT=macosx11.3 MACOSX_DEPLOYMENT_TARGET=11.3 CMAKE_OSX_DEPLOYMENT_TARGET=11.3
            #
            # Don't compile with assembler support - with asm it fails to link with arm64:
            #     ld: building for iOS, but linking in object file built for macOS, 
            #         file 'apps/ca.o' for architecture arm64"
            configure_opts=no-asm
        )
    elseif(CMAKE_SYSTEM_VERSION MATCHES "21.2.0")
        message(STATUS "[hunter] Found macOS 12.1 Monterey (uname -r: ${CMAKE_SYSTEM_VERSION})")
        hunter_config(
            Boost 
            VERSION ${HUNTER_Boost_VERSION}
            CMAKE_ARGS NOTEQUAL=arm64;x86_64
            )            
        hunter_config(
            OpenSSL
            #URL "https://www.openssl.org/source/openssl-1.1.1j.tar.gz"
            #SHA1 "04c340b086828eecff9df06dceff196790bb9268"
            URL "https://www.openssl.org/source/openssl-1.1.1m.tar.gz"
            SHA1 "39d424c4411e45f1570073d7a71b1830b96007ca"
            # it is not nessesary to explicitly specify the system arch. 
            # since OpenSSL has checks in place to look up what is availble
            #
            # IMHO: It's better to allow OpenSSL to-do the check it self, 
            # since on macOS it opens up the posibility to compile a 'Universal Binary' 
            # for both Apple M1 Silicon (arm64) & Intel X86_64 when we set the
            # varibale: CMAKE_OSX_ARCHITECTURES
            # 
            # Though if for some reason anyone wants to explcitly specify the system arch,
            # uncomment the following line:
            #CMAKE_ARGS CMAKE_C_FLAGS="-v" CMAKE_EXE_LINKER_FLAGS="-v" XCODE_ATTRIBUTE_ONLY_ACTIVE_ARCH=NO CMAKE_CROSSCOMPILING=YES CMAKE_SYSTEM_NAME=Darwin CMAKE_OSX_SYSROOT=macosx12.1 MACOSX_DEPLOYMENT_TARGET=12.1 CMAKE_OSX_DEPLOYMENT_TARGET=12.1 configure_architectures=${CMAKE_SYSTEM_PROCESSOR}
            # and comment out this line:
            CMAKE_ARGS CMAKE_C_FLAGS="-v" CMAKE_EXE_LINKER_FLAGS="-v" XCODE_ATTRIBUTE_ONLY_ACTIVE_ARCH=NO CMAKE_CROSSCOMPILING=YES CMAKE_SYSTEM_NAME=Darwin CMAKE_OSX_SYSROOT=macosx12.1 MACOSX_DEPLOYMENT_TARGET=12.1 CMAKE_OSX_DEPLOYMENT_TARGET=12.1
            #
            # Don't compile with assembler support - with asm it fails to link with arm64:
            #     ld: building for iOS, but linking in object file built for macOS, 
            #         file 'apps/ca.o' for architecture arm64"
            configure_opts=no-asm            
        )
    else()
        message(STATUS "[hunter] Found macOS *** (uname -r: ${CMAKE_SYSTEM_VERSION})")
        hunter_config(Boost VERSION ${HUNTER_Boost_VERSION})          
        hunter_config(
            OpenSSL
            #URL "https://www.openssl.org/source/openssl-1.1.1j.tar.gz"
            #SHA1 "04c340b086828eecff9df06dceff196790bb9268"
            URL "https://www.openssl.org/source/openssl-1.1.1m.tar.gz"
            SHA1 "39d424c4411e45f1570073d7a71b1830b96007ca"
            #CMAKE_ARGS configure_architectures=${CMAKE_SYSTEM_PROCESSOR}
        )
    endif()
else()
    message(STATUS "[hunter] Found other OS")
    hunter_config(Boost VERSION ${HUNTER_Boost_VERSION})
    hunter_config(
        OpenSSL
            #URL "https://www.openssl.org/source/openssl-1.1.1j.tar.gz"
            #SHA1 "04c340b086828eecff9df06dceff196790bb9268"
            URL "https://www.openssl.org/source/openssl-1.1.1m.tar.gz"
            SHA1 "39d424c4411e45f1570073d7a71b1830b96007ca"
        CMAKE_ARGS configure_architectures=${CMAKE_SYSTEM_PROCESSOR}
    )
endif()


