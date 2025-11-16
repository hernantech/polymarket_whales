import os
from flask import Flask, jsonify
from flask_cors import CORS
import psycopg2

app = Flask(__name__)
CORS(app)

# Database configuration
DB_CONFIG = {
    'host': os.getenv('DATABASE_HOST', 'localhost'),
    'port': os.getenv('DATABASE_PORT', '5432'),
    'database': os.getenv('DATABASE_NAME', 'polymarket_whales'),
    'user': os.getenv('DATABASE_USER', 'postgres'),
    'password': os.getenv('DATABASE_PASSWORD', 'changeme')
}


def get_db_connection():
    """Create a database connection."""
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        return conn
    except Exception as e:
        print(f"Database connection error: {e}")
        return None


@app.route('/')
def index():
    """Root endpoint."""
    return jsonify({
        'message': 'Polymarket Whales API',
        'version': '1.0.0',
        'status': 'running'
    })


@app.route('/health')
def health():
    """Health check endpoint."""
    db_status = 'healthy'
    try:
        conn = get_db_connection()
        if conn:
            conn.close()
        else:
            db_status = 'unhealthy'
    except Exception as e:
        db_status = f'unhealthy: {str(e)}'

    return jsonify({
        'status': 'healthy' if db_status == 'healthy' else 'degraded',
        'database': db_status
    }), 200 if db_status == 'healthy' else 503


@app.route('/ready')
def ready():
    """Readiness check endpoint."""
    try:
        conn = get_db_connection()
        if conn:
            conn.close()
            return jsonify({'status': 'ready'}), 200
        else:
            return jsonify({'status': 'not ready'}), 503
    except Exception as e:
        return jsonify({'status': 'not ready', 'error': str(e)}), 503


@app.route('/api/whales')
def get_whales():
    """Get whale data from database."""
    try:
        conn = get_db_connection()
        if not conn:
            return jsonify({'error': 'Database connection failed'}), 500

        cur = conn.cursor()
        # Example query - adjust based on your actual schema
        cur.execute("SELECT version();")
        db_version = cur.fetchone()
        cur.close()
        conn.close()

        return jsonify({
            'message': 'Whales endpoint',
            'database_version': db_version[0] if db_version else 'unknown'
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 500


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=os.getenv('FLASK_ENV') == 'development')
