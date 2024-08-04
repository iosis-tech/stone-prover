FROM ciimage/python:3.9 AS base_image

COPY install_deps.sh /app/
RUN /app/install_deps.sh

# Install Cairo0 for end-to-end test.
RUN pip install cairo-lang==0.12.0

COPY docker_common_deps.sh /app/
WORKDIR /app/
RUN ./docker_common_deps.sh
RUN chown -R starkware:starkware /app

COPY WORKSPACE /app/
COPY .bazelrc /app/
COPY src /app/src
COPY e2e_test /app/e2e_test
COPY bazel_utils /app/bazel_utils

# Build.
RUN bazel build //...

FROM base_image

# Run tests.
RUN bazel test //...

# Copy cpu_air_prover and cpu_air_verifier.
RUN ln -s /app/build/bazelbin/src/starkware/main/cpu/cpu_air_prover /bin/cpu_air_prover
RUN ln -s /app/build/bazelbin/src/starkware/main/cpu/cpu_air_verifier /bin/cpu_air_verifier