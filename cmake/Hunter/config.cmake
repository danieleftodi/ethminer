hunter_config(CURL VERSION ${HUNTER_CURL_VERSION} CMAKE_ARGS HTTP_ONLY=ON CMAKE_USE_OPENSSL=OFF CMAKE_USE_LIBSSH2=OFF CURL_CA_PATH=none)
hunter_config(Boost VERSION 1.77.0)

hunter_config(
    OpenSSL
    URL "https://www.openssl.org/source/openssl-1.1.1j.tar.gz"
    SHA1 "04c340b086828eecff9df06dceff196790bb9268"
    CMAKE_ARGS configure_architectures=${CMAKE_SYSTEM_PROCESSOR}
)
