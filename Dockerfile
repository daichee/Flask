FROM continuumio/miniconda3:latest

WORKDIR /tmp/setup

# システムパッケージの更新とロケールの設定
RUN apt-get update && apt-get install -y \
    curl \
    git \
    vim \
    && rm -rf /var/lib/apt/lists/* \
    && conda config --set channel_priority strict

# 開発環境用のconda環境を作成
COPY environment.yml .
RUN conda env create -f environment.yml && \
    echo "conda activate flask-dev" >> ~/.bashrc

# コンテナ起動時のセットアップスクリプト
RUN echo '#!/bin/bash\n\
\n\
# Activate conda environment\n\
. /opt/conda/etc/profile.d/conda.sh && \
conda activate flask-dev\n\
\n\
# Create initial project structure if it doesnt exist\n\
if [ ! -f "/app/app.py" ]; then\n\
    cd /app\n\
    mkdir -p app/models app/routes app/templates app/static/css app/static/js\n\
\n\
    # Create app/__init__.py\n\
    cat > app/__init__.py << "EOF"\n\
from flask import Flask\n\
from flask_sqlalchemy import SQLAlchemy\n\
\n\
db = SQLAlchemy()\n\
\n\
def create_app():\n\
    app = Flask(__name__)\n\
    app.config.from_object("config.Config")\n\
    db.init_app(app)\n\
    from app.routes import main_bp\n\
    app.register_blueprint(main_bp)\n\
    return app\n\
EOF\n\
\n\
    # Create app/routes/__init__.py\n\
    cat > app/routes/__init__.py << "EOF"\n\
from flask import Blueprint, render_template\n\
\n\
main_bp = Blueprint("main", __name__)\n\
\n\
@main_bp.route("/")\n\
def index():\n\
    return render_template("index.html")\n\
EOF\n\
\n\
    # Create app/templates/base.html\n\
    cat > app/templates/base.html << "EOF"\n\
<!DOCTYPE html>\n\
<html lang="ja">\n\
<head>\n\
    <meta charset="UTF-8">\n\
    <meta name="viewport" content="width=device-width, initial-scale=1.0">\n\
    <title>{% block title %}{% endblock %} - Flask App</title>\n\
</head>\n\
<body>\n\
    <main>\n\
        {% block content %}{% endblock %}\n\
    </main>\n\
</body>\n\
</html>\n\
EOF\n\
\n\
    # Create app/templates/index.html\n\
    cat > app/templates/index.html << "EOF"\n\
{% extends "base.html" %}\n\
\n\
{% block title %}Home{% endblock %}\n\
\n\
{% block content %}\n\
<div class="container">\n\
    <h1>Welcome to Flask</h1>\n\
    <p>Your application is running successfully!</p>\n\
</div>\n\
{% endblock %}\n\
EOF\n\
\n\
    # Create config.py\n\
    cat > config.py << "EOF"\n\
import os\n\
\n\
class Config:\n\
    SECRET_KEY = os.environ.get("SECRET_KEY") or "dev-key-please-change"\n\
    SQLALCHEMY_DATABASE_URI = os.environ.get("DATABASE_URL") or \\\n\
        "postgresql://flask_user:flask_password@db/flask_db"\n\
    SQLALCHEMY_TRACK_MODIFICATIONS = False\n\
EOF\n\
\n\
    # Create app.py\n\
    cat > app.py << "EOF"\n\
from app import create_app\n\
\n\
app = create_app()\n\
\n\
if __name__ == "__main__":\n\
    app.run(host="0.0.0.0", debug=True)\n\
EOF\n\
\n\
    # Create empty __init__.py files\n\
    touch app/models/__init__.py\n\
fi\n\
\n\
# Start application with retry logic\n\
start_time=$(date +%s)\n\
max_duration=3600  # 30分（秒単位）\n\
retry_delay=30    # 1分待機（秒単位）\n\
\n\
while true; do\n\
    echo "Starting Flask application..."\n\
    python app.py\n\
    \n\
    # エラーが発生した場合\n\
    current_time=$(date +%s)\n\
    elapsed_time=$((current_time - start_time))\n\
    \n\
    if [ $elapsed_time -gt $max_duration ]; then\n\
        echo "Application failed for 60 minutes. Keeping container alive..."\n\
        exec tail -f /dev/null\n\
    else\n\
        minutes=$((elapsed_time / 60))\n\
        seconds=$((elapsed_time % 30))\n\
        echo "Flask application crashed. Waiting 30 seconds before retry... (Total elapsed time: ${minutes}m ${seconds}s)"\n\
        sleep $retry_delay\n\
    fi\n\
done\n\
' > /docker-entrypoint.sh && chmod +x /docker-entrypoint.sh

WORKDIR /app

# Set entrypoint
ENTRYPOINT ["/docker-entrypoint.sh"]