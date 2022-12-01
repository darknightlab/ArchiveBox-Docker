FROM archivebox/archivebox:latest

# Install Node dependencies
WORKDIR "$NODE_DIR"
RUN rm -rf * !(package.json)
ENV PATH="${PATH}:$NODE_DIR/node_modules/.bin" \
    npm_config_loglevel=error
# ADD ./package.json ./package.json
# ADD ./package-lock.json ./package-lock.json
RUN npm i

# Install ArchiveBox Python package and its dependencies
WORKDIR "$CODE_DIR"
# ADD . "$CODE_DIR"
RUN sed -i '/DEPENDENCIES\[/a\        "--load-deferred-images-dispatch-scroll-event=true",' "$CODE_DIR/archivebox/extractors/singlefile.py"
RUN pip install -e .

# Setup ArchiveBox runtime config
WORKDIR "$DATA_DIR"

# Optional:
# HEALTHCHECK --interval=30s --timeout=20s --retries=15 \
#     CMD curl --silent 'http://localhost:8000/admin/login/' || exit 1

ENTRYPOINT ["dumb-init", "--", "/app/bin/docker_entrypoint.sh"]
CMD ["archivebox", "server", "--quick-init", "0.0.0.0:8000"]
