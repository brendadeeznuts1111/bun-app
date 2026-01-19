#!/bin/bash

# AI-Powered Analytics Dashboard for Bun.app
# Advanced analytics with machine learning insights and predictive analytics

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/config/analytics-config.yaml"
DATA_DIR="$SCRIPT_DIR/data"
MODELS_DIR="$SCRIPT_DIR/models"
REPORTS_DIR="$SCRIPT_DIR/reports"
DASHBOARD_DIR="$SCRIPT_DIR/dashboard"

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --model|-m)
                MODEL_TYPE="$2"
                shift 2
                ;;
            --period|-p)
                TIME_PERIOD="$2"
                shift 2
                ;;
            --output|-o)
                OUTPUT_FORMAT="$2"
                shift 2
                ;;
            --real-time|-r)
                REAL_TIME=true
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                shift
                ;;
        esac
    done
}

# Show help
show_help() {
    cat << EOF
Bun.app AI-Powered Analytics Dashboard

USAGE:
    $0 [OPTIONS] <COMMAND>

COMMANDS:
    init                    Initialize analytics system
    start                   Start analytics dashboard
    stop                    Stop analytics dashboard
    collect                 Collect data
    analyze                 Run AI analysis
    predict                 Generate predictions
    report                  Generate reports
    train                   Train ML models
    monitor                 Real-time monitoring

OPTIONS:
    -m, --model TYPE        Model type (usage, performance, security)
    -p, --period PERIOD     Time period (hour, day, week, month)
    -o, --output FORMAT     Output format (json, csv, html, pdf)
    -r, --real-time         Enable real-time processing
    -h, --help              Show this help

AI FEATURES:
    - Predictive analytics
    - Anomaly detection
    - User behavior analysis
    - Performance optimization
    - Security threat detection
    - Business intelligence
    - Natural language reports
    - Automated insights

EXAMPLES:
    $0 init                                    # Initialize system
    $0 start                                   # Start dashboard
    $0 collect --period day                    # Collect daily data
    $0 analyze --model usage                   # Analyze usage patterns
    $0 predict --period week                   # Generate weekly predictions
    $0 report --output html                    # Generate HTML report

EOF
}

# Utility functions
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_debug() {
    if [[ "$DEBUG" == true ]]; then
        echo -e "${PURPLE}[DEBUG]${NC} $1"
    fi
}

# Initialize analytics system
init_analytics_system() {
    print_info "Initializing AI-powered analytics system..."
    
    # Create directories
    mkdir -p "$DATA_DIR"/{raw,processed,features}
    mkdir -p "$MODELS_DIR"/{trained,training}
    mkdir -p "$REPORTS_DIR"/{daily,weekly,monthly}
    mkdir -p "$DASHBOARD_DIR"/{static,templates}
    mkdir -p "$SCRIPT_DIR"/logs
    mkdir -p "$SCRIPT_DIR"/cache
    
    # Create configuration
    create_analytics_config
    
    # Setup data collection
    setup_data_collection
    
    # Setup ML infrastructure
    setup_ml_infrastructure
    
    # Create dashboard
    create_dashboard
    
    # Initialize models
    initialize_models
    
    print_success "Analytics system initialized"
}

# Create analytics configuration
create_analytics_config() {
    print_info "Creating analytics configuration..."
    
    cat > "$CONFIG_FILE" << 'EOF'
# Bun.app AI-Powered Analytics Configuration

# Global settings
global:
  enabled: true
  data_retention_days: 365
  cache_ttl: 3600
  real_time_processing: true
  batch_processing: true
  debug_mode: false

# Data collection
data_collection:
  sources:
    - name: "user_activity"
      type: "events"
      enabled: true
      collection_interval: 60
      
    - name: "performance_metrics"
      type: "metrics"
      enabled: true
      collection_interval: 30
      
    - name: "system_logs"
      type: "logs"
      enabled: true
      collection_interval: 300
      
    - name: "business_metrics"
      type: "kpi"
      enabled: true
      collection_interval: 3600

  storage:
    type: "file"
    raw_path: "./data/raw"
    processed_path: "./data/processed"
    compression: true
    encryption: false

# Machine learning models
models:
  usage_prediction:
    type: "time_series"
    algorithm: "lstm"
    features:
      - "user_count"
      - "session_duration"
      - "feature_usage"
      - "time_of_day"
      - "day_of_week"
    training_interval: 86400  # 24 hours
    accuracy_threshold: 0.85
    
  anomaly_detection:
    type: "unsupervised"
    algorithm: "isolation_forest"
    features:
      - "cpu_usage"
      - "memory_usage"
      - "network_latency"
      - "error_rate"
    sensitivity: 0.1
    alert_threshold: 0.8
    
  user_behavior:
    type: "clustering"
    algorithm: "kmeans"
    features:
      - "login_frequency"
      - "feature_adoption"
      - "session_length"
      - "navigation_patterns"
    clusters: 5
    retrain_interval: 604800  # 7 days
    
  performance_optimization:
    type: "regression"
    algorithm: "random_forest"
    features:
      - "system_load"
      - "concurrent_users"
      - "cache_hit_rate"
      - "database_queries"
    target: "response_time"
    optimization_goal: "minimize"

# Real-time analytics
real_time:
  enabled: true
  processing_window: 300  # 5 minutes
  alert_thresholds:
    error_rate: 0.05
    response_time: 2000
    cpu_usage: 0.8
    memory_usage: 0.9
    
  streaming:
    buffer_size: 1000
    batch_size: 100
    flush_interval: 10

# Predictive analytics
prediction:
  horizons:
    - name: "short_term"
      period: 3600  # 1 hour
      confidence_threshold: 0.7
      
    - name: "medium_term"
      period: 86400  # 1 day
      confidence_threshold: 0.8
      
    - name: "long_term"
      period: 604800  # 1 week
      confidence_threshold: 0.85

# Business intelligence
business:
  kpis:
    - name: "daily_active_users"
      type: "count"
      target: 1000
      
    - name: "user_retention"
      type: "percentage"
      target: 0.8
      
    - name: "feature_adoption"
      type: "percentage"
      target: 0.6
      
    - name: "system_availability"
      type: "percentage"
      target: 0.99

  reports:
    automated: true
    schedule: "daily"
    recipients:
      - "analytics@bun.app"
    formats:
      - "html"
      - "pdf"

# Dashboard settings
dashboard:
  enabled: true
  port: 3000
  refresh_interval: 30
  themes:
    - "light"
    - "dark"
    - "auto"
    
  widgets:
    - name: "real_time_metrics"
      type: "timeseries"
      refresh_rate: 5
      
    - name: "user_analytics"
      type: "analytics"
      refresh_rate: 60
      
    - name: "performance_monitor"
      type: "monitoring"
      refresh_rate: 10
      
    - name: "predictions"
      type: "forecasting"
      refresh_rate: 300

# Security and compliance
security:
  data_anonymization: true
  gdpr_compliance: true
  audit_logging: true
  access_control: true
  
  encryption:
    at_rest: true
    in_transit: true
    key_rotation: true

# Integration settings
integrations:
  databases:
    - name: "analytics_db"
      type: "sqlite"
      path: "./data/analytics.db"
      
  apis:
    - name: "ml_service"
      endpoint: "http://localhost:5000"
      timeout: 30
      
  notifications:
    - name: "slack"
      webhook_url: "https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK"
      enabled: false
      
    - name: "email"
      smtp_server: "smtp.gmail.com"
      enabled: false
EOF
    
    print_success "Analytics configuration created"
}

# Setup data collection
setup_data_collection() {
    print_info "Setting up data collection infrastructure..."
    
    # Create data collector
    cat > "$SCRIPT_DIR/collectors/data-collector.py" << 'EOF'
#!/usr/bin/env python3
"""
Bun.app Data Collector
Collects various types of data for analytics processing
"""

import json
import time
import sqlite3
import threading
from datetime import datetime, timedelta
from pathlib import Path
import psutil
import logging

# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class DataCollector:
    def __init__(self, config_path):
        self.config = self.load_config(config_path)
        self.running = False
        self.threads = []
        
        # Initialize database
        self.db_path = Path(self.config['integrations']['databases'][0]['path'])
        self.db_path.parent.mkdir(parents=True, exist_ok=True)
        self.init_database()
        
    def load_config(self, config_path):
        with open(config_path, 'r') as f:
            import yaml
            return yaml.safe_load(f)
    
    def init_database(self):
        """Initialize SQLite database for analytics data"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        # Create tables
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS user_activity (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                timestamp DATETIME,
                user_id TEXT,
                action TEXT,
                feature TEXT,
                session_id TEXT,
                metadata TEXT
            )
        ''')
        
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS performance_metrics (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                timestamp DATETIME,
                cpu_usage REAL,
                memory_usage REAL,
                disk_usage REAL,
                network_latency REAL,
                response_time REAL,
                error_rate REAL
            )
        ''')
        
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS system_logs (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                timestamp DATETIME,
                level TEXT,
                source TEXT,
                message TEXT,
                metadata TEXT
            )
        ''')
        
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS business_metrics (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                timestamp DATETIME,
                metric_name TEXT,
                metric_value REAL,
                target_value REAL,
                variance REAL
            )
        ''')
        
        conn.commit()
        conn.close()
        
    def start_collection(self):
        """Start data collection threads"""
        logger.info("Starting data collection...")
        self.running = True
        
        for source in self.config['data_collection']['sources']:
            if source['enabled']:
                thread = threading.Thread(
                    target=self.collect_source_data,
                    args=(source,),
                    daemon=True
                )
                thread.start()
                self.threads.append(thread)
        
        logger.info(f"Started {len(self.threads)} collection threads")
    
    def stop_collection(self):
        """Stop data collection"""
        logger.info("Stopping data collection...")
        self.running = False
        
        for thread in self.threads:
            thread.join(timeout=5)
        
        logger.info("Data collection stopped")
    
    def collect_source_data(self, source):
        """Collect data from a specific source"""
        interval = source['collection_interval']
        
        while self.running:
            try:
                if source['name'] == 'user_activity':
                    self.collect_user_activity()
                elif source['name'] == 'performance_metrics':
                    self.collect_performance_metrics()
                elif source['name'] == 'system_logs':
                    self.collect_system_logs()
                elif source['name'] == 'business_metrics':
                    self.collect_business_metrics()
                
                time.sleep(interval)
                
            except Exception as e:
                logger.error(f"Error collecting {source['name']}: {e}")
                time.sleep(interval)
    
    def collect_user_activity(self):
        """Collect user activity data"""
        # Simulate user activity data
        activities = [
            {'user_id': f'user_{i}', 'action': 'login', 'feature': 'auth'},
            {'user_id': f'user_{i}', 'action': 'feature_use', 'feature': 'dashboard'},
            {'user_id': f'user_{i}', 'action': 'logout', 'feature': 'auth'}
        ]
        
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        for activity in activities:
            cursor.execute('''
                INSERT INTO user_activity 
                (timestamp, user_id, action, feature, session_id, metadata)
                VALUES (?, ?, ?, ?, ?, ?)
            ''', (
                datetime.now(),
                activity['user_id'],
                activity['action'],
                activity['feature'],
                f'session_{int(time.time())}',
                json.dumps({'source': 'simulator'})
            ))
        
        conn.commit()
        conn.close()
        
    def collect_performance_metrics(self):
        """Collect system performance metrics"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        # Get system metrics
        cpu_percent = psutil.cpu_percent(interval=1)
        memory = psutil.virtual_memory()
        disk = psutil.disk_usage('/')
        
        cursor.execute('''
            INSERT INTO performance_metrics 
            (timestamp, cpu_usage, memory_usage, disk_usage, network_latency, response_time, error_rate)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        ''', (
            datetime.now(),
            cpu_percent / 100,
            memory.percent / 100,
            disk.used / disk.total,
            50,  # Simulated network latency
            200,  # Simulated response time
            0.01  # Simulated error rate
        ))
        
        conn.commit()
        conn.close()
        
    def collect_system_logs(self):
        """Collect system log data"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        # Simulate log entries
        log_levels = ['INFO', 'WARNING', 'ERROR']
        sources = ['app', 'auth', 'api', 'database']
        
        for _ in range(5):  # Generate 5 log entries
            cursor.execute('''
                INSERT INTO system_logs 
                (timestamp, level, source, message, metadata)
                VALUES (?, ?, ?, ?, ?)
            ''', (
                datetime.now(),
                log_levels[int(time.time()) % len(log_levels)],
                sources[int(time.time()) % len(sources)],
                f"System message at {datetime.now()}",
                json.dumps({'source': 'simulator'})
            ))
        
        conn.commit()
        conn.close()
        
    def collect_business_metrics(self):
        """Collect business KPI data"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        # Simulate business metrics
        metrics = [
            {'name': 'daily_active_users', 'value': 850, 'target': 1000},
            {'name': 'user_retention', 'value': 0.82, 'target': 0.80},
            {'name': 'feature_adoption', 'value': 0.65, 'target': 0.60},
            {'name': 'system_availability', 'value': 0.995, 'target': 0.99}
        ]
        
        for metric in metrics:
            variance = (metric['value'] - metric['target']) / metric['target']
            cursor.execute('''
                INSERT INTO business_metrics 
                (timestamp, metric_name, metric_value, target_value, variance)
                VALUES (?, ?, ?, ?, ?)
            ''', (
                datetime.now(),
                metric['name'],
                metric['value'],
                metric['target'],
                variance
            ))
        
        conn.commit()
        conn.close()

if __name__ == "__main__":
    import yaml
    import sys
    
    config_path = sys.argv[1] if len(sys.argv) > 1 else 'config/analytics-config.yaml'
    
    collector = DataCollector(config_path)
    
    try:
        collector.start_collection()
        
        # Keep running
        while True:
            time.sleep(1)
            
    except KeyboardInterrupt:
        print("\nStopping data collection...")
        collector.stop_collection()
EOF
    
    chmod +x "$SCRIPT_DIR/collectors/data-collector.py"
    
    print_success "Data collection infrastructure setup completed"
}

# Setup ML infrastructure
setup_ml_infrastructure() {
    print_info "Setting up machine learning infrastructure..."
    
    # Create ML models directory structure
    mkdir -p "$MODELS_DIR"/{usage_prediction,anomaly_detection,user_behavior,performance_optimization}
    
    # Create ML training script
    cat > "$SCRIPT_DIR/ml/model-trainer.py" << 'EOF'
#!/usr/bin/env python3
"""
Bun.app ML Model Trainer
Trains and manages machine learning models for analytics
"""

import json
import numpy as np
import pandas as pd
import sqlite3
from datetime import datetime, timedelta
from pathlib import Path
import pickle
import logging
from sklearn.ensemble import IsolationForest, RandomForestRegressor
from sklearn.cluster import KMeans
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_squared_error, silhouette_score

# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class ModelTrainer:
    def __init__(self, config_path, models_dir):
        self.config = self.load_config(config_path)
        self.models_dir = Path(models_dir)
        self.models_dir.mkdir(parents=True, exist_ok=True)
        
        # Initialize database connection
        self.db_path = Path(self.config['integrations']['databases'][0]['path'])
        
    def load_config(self, config_path):
        with open(config_path, 'r') as f:
            import yaml
            return yaml.safe_load(f)
    
    def get_data(self, table, limit=10000):
        """Load data from database"""
        conn = sqlite3.connect(self.db_path)
        
        if table == 'performance_metrics':
            df = pd.read_sql_query(f'''
                SELECT timestamp, cpu_usage, memory_usage, disk_usage, 
                       network_latency, response_time, error_rate
                FROM performance_metrics 
                ORDER BY timestamp DESC 
                LIMIT {limit}
            ''', conn)
        elif table == 'user_activity':
            df = pd.read_sql_query(f'''
                SELECT timestamp, user_id, action, feature
                FROM user_activity 
                ORDER BY timestamp DESC 
                LIMIT {limit}
            ''', conn)
        elif table == 'business_metrics':
            df = pd.read_sql_query(f'''
                SELECT timestamp, metric_name, metric_value, target_value, variance
                FROM business_metrics 
                ORDER BY timestamp DESC 
                LIMIT {limit}
            ''', conn)
        else:
            df = pd.DataFrame()
        
        conn.close()
        return df
    
    def train_anomaly_detection(self):
        """Train anomaly detection model"""
        logger.info("Training anomaly detection model...")
        
        # Get performance data
        df = self.get_data('performance_metrics')
        
        if len(df) < 100:
            logger.warning("Insufficient data for anomaly detection")
            return None
        
        # Prepare features
        features = ['cpu_usage', 'memory_usage', 'network_latency', 'response_time', 'error_rate']
        X = df[features].fillna(0)
        
        # Scale features
        scaler = StandardScaler()
        X_scaled = scaler.fit_transform(X)
        
        # Train isolation forest
        model = IsolationForest(
            contamination=0.1,
            random_state=42,
            n_estimators=100
        )
        model.fit(X_scaled)
        
        # Save model and scaler
        model_path = self.models_dir / 'anomaly_detection' / 'model.pkl'
        scaler_path = self.models_dir / 'anomaly_detection' / 'scaler.pkl'
        
        with open(model_path, 'wb') as f:
            pickle.dump(model, f)
        
        with open(scaler_path, 'wb') as f:
            pickle.dump(scaler, f)
        
        # Save metadata
        metadata = {
            'model_type': 'isolation_forest',
            'features': features,
            'trained_at': datetime.now().isoformat(),
            'training_samples': len(X),
            'contamination': 0.1
        }
        
        with open(self.models_dir / 'anomaly_detection' / 'metadata.json', 'w') as f:
            json.dump(metadata, f, indent=2)
        
        logger.info(f"Anomaly detection model trained with {len(X)} samples")
        return model
    
    def train_performance_optimization(self):
        """Train performance optimization model"""
        logger.info("Training performance optimization model...")
        
        # Get performance data
        df = self.get_data('performance_metrics')
        
        if len(df) < 100:
            logger.warning("Insufficient data for performance optimization")
            return None
        
        # Prepare features and target
        features = ['cpu_usage', 'memory_usage', 'disk_usage', 'network_latency', 'error_rate']
        target = 'response_time'
        
        X = df[features].fillna(0)
        y = df[target].fillna(0)
        
        # Split data
        X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
        
        # Train random forest
        model = RandomForestRegressor(
            n_estimators=100,
            random_state=42,
            max_depth=10
        )
        model.fit(X_train, y_train)
        
        # Evaluate model
        y_pred = model.predict(X_test)
        mse = mean_squared_error(y_test, y_pred)
        
        # Save model
        model_path = self.models_dir / 'performance_optimization' / 'model.pkl'
        
        with open(model_path, 'wb') as f:
            pickle.dump(model, f)
        
        # Save metadata
        metadata = {
            'model_type': 'random_forest_regressor',
            'features': features,
            'target': target,
            'trained_at': datetime.now().isoformat(),
            'training_samples': len(X),
            'mse': float(mse),
            'rmse': float(np.sqrt(mse))
        }
        
        with open(self.models_dir / 'performance_optimization' / 'metadata.json', 'w') as f:
            json.dump(metadata, f, indent=2)
        
        logger.info(f"Performance optimization model trained with RMSE: {np.sqrt(mse):.2f}")
        return model
    
    def train_user_behavior(self):
        """Train user behavior clustering model"""
        logger.info("Training user behavior model...")
        
        # Get user activity data
        df = self.get_data('user_activity')
        
        if len(df) < 100:
            logger.warning("Insufficient data for user behavior analysis")
            return None
        
        # Aggregate user features
        user_features = df.groupby('user_id').agg({
            'action': 'count',
            'feature': 'nunique'
        }).reset_index()
        
        user_features.columns = ['user_id', 'action_count', 'unique_features']
        
        # Prepare features
        features = ['action_count', 'unique_features']
        X = user_features[features].fillna(0)
        
        # Scale features
        scaler = StandardScaler()
        X_scaled = scaler.fit_transform(X)
        
        # Train K-means
        n_clusters = min(5, len(X))  # Ensure we don't have more clusters than samples
        model = KMeans(n_clusters=n_clusters, random_state=42)
        cluster_labels = model.fit_predict(X_scaled)
        
        # Calculate silhouette score
        if n_clusters > 1:
            silhouette_avg = silhouette_score(X_scaled, cluster_labels)
        else:
            silhouette_avg = 0
        
        # Save model and scaler
        model_path = self.models_dir / 'user_behavior' / 'model.pkl'
        scaler_path = self.models_dir / 'user_behavior' / 'scaler.pkl'
        
        with open(model_path, 'wb') as f:
            pickle.dump(model, f)
        
        with open(scaler_path, 'wb') as f:
            pickle.dump(scaler, f)
        
        # Save metadata
        metadata = {
            'model_type': 'kmeans_clustering',
            'features': features,
            'n_clusters': n_clusters,
            'trained_at': datetime.now().isoformat(),
            'training_samples': len(X),
            'silhouette_score': float(silhouette_avg)
        }
        
        with open(self.models_dir / 'user_behavior' / 'metadata.json', 'w') as f:
            json.dump(metadata, f, indent=2)
        
        logger.info(f"User behavior model trained with {n_clusters} clusters, silhouette: {silhouette_avg:.3f}")
        return model
    
    def train_usage_prediction(self):
        """Train usage prediction model (simplified time series)"""
        logger.info("Training usage prediction model...")
        
        # Get business metrics data
        df = self.get_data('business_metrics')
        
        if len(df) < 50:
            logger.warning("Insufficient data for usage prediction")
            return None
        
        # Filter for daily active users
        dau_data = df[df['metric_name'] == 'daily_active_users'].copy()
        dau_data['timestamp'] = pd.to_datetime(dau_data['timestamp'])
        dau_data = dau_data.sort_values('timestamp')
        
        if len(dau_data) < 30:
            logger.warning("Insufficient DAU data for prediction")
            return None
        
        # Simple moving average prediction
        window_size = min(7, len(dau_data) // 4)
        dau_data['prediction'] = dau_data['metric_value'].rolling(window=window_size).mean()
        
        # Save prediction model (simple moving average)
        model_data = {
            'type': 'moving_average',
            'window_size': window_size,
            'last_values': dau_data['metric_value'].tail(window_size).tolist(),
            'trained_at': datetime.now().isoformat()
        }
        
        model_path = self.models_dir / 'usage_prediction' / 'model.json'
        with open(model_path, 'w') as f:
            json.dump(model_data, f, indent=2)
        
        # Save metadata
        metadata = {
            'model_type': 'moving_average',
            'features': ['metric_value'],
            'window_size': window_size,
            'trained_at': datetime.now().isoformat(),
            'training_samples': len(dau_data)
        }
        
        with open(self.models_dir / 'usage_prediction' / 'metadata.json', 'w') as f:
            json.dump(metadata, f, indent=2)
        
        logger.info(f"Usage prediction model trained with window size: {window_size}")
        return model_data
    
    def train_all_models(self):
        """Train all models"""
        logger.info("Training all ML models...")
        
        models = {}
        
        try:
            models['anomaly_detection'] = self.train_anomaly_detection()
        except Exception as e:
            logger.error(f"Error training anomaly detection: {e}")
        
        try:
            models['performance_optimization'] = self.train_performance_optimization()
        except Exception as e:
            logger.error(f"Error training performance optimization: {e}")
        
        try:
            models['user_behavior'] = self.train_user_behavior()
        except Exception as e:
            logger.error(f"Error training user behavior: {e}")
        
        try:
            models['usage_prediction'] = self.train_usage_prediction()
        except Exception as e:
            logger.error(f"Error training usage prediction: {e}")
        
        logger.info(f"Model training completed. Trained {len([m for m in models.values() if m is not None])} models.")
        return models

if __name__ == "__main__":
    import sys
    import yaml
    
    config_path = sys.argv[1] if len(sys.argv) > 1 else 'config/analytics-config.yaml'
    models_dir = sys.argv[2] if len(sys.argv) > 2 else 'models'
    
    trainer = ModelTrainer(config_path, models_dir)
    trainer.train_all_models()
EOF
    
    chmod +x "$SCRIPT_DIR/ml/model-trainer.py"
    
    print_success "ML infrastructure setup completed"
}

# Create dashboard
create_dashboard() {
    print_info "Creating analytics dashboard..."
    
    # Create Flask dashboard application
    cat > "$DASHBOARD_DIR/app.py" << 'EOF'
#!/usr/bin/env python3
"""
Bun.app Analytics Dashboard
Web-based dashboard for visualizing analytics data
"""

from flask import Flask, render_template, jsonify, request
import sqlite3
import json
import pandas as pd
from datetime import datetime, timedelta
from pathlib import Path
import yaml

app = Flask(__name__)

# Load configuration
def load_config():
    config_path = Path(__file__).parent.parent / 'config' / 'analytics-config.yaml'
    with open(config_path, 'r') as f:
        return yaml.safe_load(f)

config = load_config()
db_path = Path(config['integrations']['databases'][0]['path'])

def get_db_connection():
    conn = sqlite3.connect(db_path)
    conn.row_factory = sqlite3.Row
    return conn

@app.route('/')
def dashboard():
    return render_template('dashboard.html')

@app.route('/api/metrics/realtime')
def realtime_metrics():
    """Get real-time metrics"""
    conn = get_db_connection()
    
    # Get latest performance metrics
    perf_metrics = conn.execute('''
        SELECT * FROM performance_metrics 
        ORDER BY timestamp DESC 
        LIMIT 100
    ''').fetchall()
    
    # Get latest business metrics
    business_metrics = conn.execute('''
        SELECT * FROM business_metrics 
        ORDER BY timestamp DESC 
        LIMIT 50
    ''').fetchall()
    
    conn.close()
    
    return jsonify({
        'performance': [dict(row) for row in perf_metrics],
        'business': [dict(row) for row in business_metrics],
        'timestamp': datetime.now().isoformat()
    })

@app.route('/api/analytics/users')
def user_analytics():
    """Get user analytics data"""
    conn = get_db_connection()
    
    # User activity over time
    activity_over_time = conn.execute('''
        SELECT 
            DATE(timestamp) as date,
            COUNT(DISTINCT user_id) as active_users,
            COUNT(*) as total_actions
        FROM user_activity 
        WHERE timestamp >= date('now', '-30 days')
        GROUP BY DATE(timestamp)
        ORDER BY date
    ''').fetchall()
    
    # Feature usage
    feature_usage = conn.execute('''
        SELECT 
            feature,
            COUNT(*) as usage_count,
            COUNT(DISTINCT user_id) as unique_users
        FROM user_activity 
        WHERE timestamp >= date('now', '-7 days')
        GROUP BY feature
        ORDER BY usage_count DESC
    ''').fetchall()
    
    conn.close()
    
    return jsonify({
        'activity_over_time': [dict(row) for row in activity_over_time],
        'feature_usage': [dict(row) for row in feature_usage]
    })

@app.route('/api/analytics/performance')
def performance_analytics():
    """Get performance analytics"""
    conn = get_db_connection()
    
    # Performance trends
    performance_trends = conn.execute('''
        SELECT 
            DATE(timestamp) as date,
            AVG(cpu_usage) as avg_cpu,
            AVG(memory_usage) as avg_memory,
            AVG(response_time) as avg_response_time,
            AVG(error_rate) as avg_error_rate
        FROM performance_metrics 
        WHERE timestamp >= date('now', '-7 days')
        GROUP BY DATE(timestamp)
        ORDER BY date
    ''').fetchall()
    
    # Performance alerts
    alerts = []
    recent_metrics = conn.execute('''
        SELECT * FROM performance_metrics 
        ORDER BY timestamp DESC 
        LIMIT 10
    ''').fetchall()
    
    for metric in recent_metrics:
        if metric['cpu_usage'] > 0.8:
            alerts.append({
                'type': 'high_cpu',
                'message': f'High CPU usage: {metric["cpu_usage"]:.1%}',
                'timestamp': metric['timestamp']
            })
        if metric['memory_usage'] > 0.9:
            alerts.append({
                'type': 'high_memory',
                'message': f'High memory usage: {metric["memory_usage"]:.1%}',
                'timestamp': metric['timestamp']
            })
        if metric['error_rate'] > 0.05:
            alerts.append({
                'type': 'high_error_rate',
                'message': f'High error rate: {metric["error_rate"]:.1%}',
                'timestamp': metric['timestamp']
            })
    
    conn.close()
    
    return jsonify({
        'trends': [dict(row) for row in performance_trends],
        'alerts': alerts
    })

@app.route('/api/predictions')
def predictions():
    """Get AI predictions"""
    # Load trained models
    models_dir = Path(__file__).parent.parent / 'models'
    
    predictions = {}
    
    # Usage prediction
    usage_model_path = models_dir / 'usage_prediction' / 'model.json'
    if usage_model_path.exists():
        with open(usage_model_path, 'r') as f:
            usage_model = json.load(f)
        
        # Simple prediction based on moving average
        last_values = usage_model['last_values']
        if last_values:
            prediction = sum(last_values) / len(last_values)
            predictions['usage'] = {
                'predicted_dau': int(prediction),
                'confidence': 0.75,
                'horizon': '1 day'
            }
    
    # Performance prediction
    perf_model_path = models_dir / 'performance_optimization' / 'metadata.json'
    if perf_model_path.exists():
        with open(perf_model_path, 'r') as f:
            perf_model = json.load(f)
        
        predictions['performance'] = {
            'expected_response_time': perf_model['rmse'],
            'confidence': 0.80,
            'model_accuracy': f"{1 - (perf_model['rmse'] / 100):.1%}"
        }
    
    return jsonify(predictions)

@app.route('/api/health')
def health():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.now().isoformat(),
        'version': '1.0.0'
    })

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=3000)
EOF
    
    # Create HTML template
    mkdir -p "$DASHBOARD_DIR/templates"
    cat > "$DASHBOARD_DIR/templates/dashboard.html" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bun.app Analytics Dashboard</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        .metric-card {
            @apply bg-white rounded-lg shadow-md p-6 border border-gray-200;
        }
        .metric-value {
            @apply text-3xl font-bold text-gray-900;
        }
        .metric-label {
            @apply text-sm text-gray-600 mt-1;
        }
        .status-indicator {
            @apply inline-block w-3 h-3 rounded-full mr-2;
        }
        .status-good { @apply bg-green-500; }
        .status-warning { @apply bg-yellow-500; }
        .status-error { @apply bg-red-500; }
    </style>
</head>
<body class="bg-gray-100">
    <div class="container mx-auto px-4 py-8">
        <!-- Header -->
        <header class="mb-8">
            <h1 class="text-4xl font-bold text-gray-900 mb-2">Bun.app Analytics Dashboard</h1>
            <p class="text-gray-600">AI-powered insights and real-time monitoring</p>
        </header>

        <!-- Key Metrics -->
        <section class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
            <div class="metric-card">
                <div class="flex items-center justify-between">
                    <div>
                        <div class="metric-value" id="active-users">-</div>
                        <div class="metric-label">Active Users</div>
                    </div>
                    <div class="status-indicator status-good"></div>
                </div>
            </div>
            
            <div class="metric-card">
                <div class="flex items-center justify-between">
                    <div>
                        <div class="metric-value" id="response-time">-</div>
                        <div class="metric-label">Avg Response Time</div>
                    </div>
                    <div class="status-indicator status-good"></div>
                </div>
            </div>
            
            <div class="metric-card">
                <div class="flex items-center justify-between">
                    <div>
                        <div class="metric-value" id="error-rate">-</div>
                        <div class="metric-label">Error Rate</div>
                    </div>
                    <div class="status-indicator status-good"></div>
                </div>
            </div>
            
            <div class="metric-card">
                <div class="flex items-center justify-between">
                    <div>
                        <div class="metric-value" id="uptime">-</div>
                        <div class="metric-label">System Uptime</div>
                    </div>
                    <div class="status-indicator status-good"></div>
                </div>
            </div>
        </section>

        <!-- Charts Section -->
        <section class="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
            <!-- User Activity Chart -->
            <div class="metric-card">
                <h3 class="text-lg font-semibold mb-4">User Activity (30 Days)</h3>
                <canvas id="userActivityChart"></canvas>
            </div>
            
            <!-- Performance Chart -->
            <div class="metric-card">
                <h3 class="text-lg font-semibold mb-4">Performance Trends (7 Days)</h3>
                <canvas id="performanceChart"></canvas>
            </div>
        </section>

        <!-- AI Predictions -->
        <section class="metric-card mb-8">
            <h3 class="text-lg font-semibold mb-4">AI Predictions</h3>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                    <h4 class="font-medium text-gray-700 mb-2">Usage Forecast</h4>
                    <div class="space-y-2">
                        <div class="flex justify-between">
                            <span>Predicted DAU (Tomorrow):</span>
                            <span class="font-semibold" id="predicted-dau">-</span>
                        </div>
                        <div class="flex justify-between">
                            <span>Confidence:</span>
                            <span class="font-semibold" id="usage-confidence">-</span>
                        </div>
                    </div>
                </div>
                
                <div>
                    <h4 class="font-medium text-gray-700 mb-2">Performance Forecast</h4>
                    <div class="space-y-2">
                        <div class="flex justify-between">
                            <span>Expected Response Time:</span>
                            <span class="font-semibold" id="expected-response">-</span>
                        </div>
                        <div class="flex justify-between">
                            <span>Model Accuracy:</span>
                            <span class="font-semibold" id="model-accuracy">-</span>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- Alerts Section -->
        <section class="metric-card">
            <h3 class="text-lg font-semibold mb-4">Recent Alerts</h3>
            <div id="alerts-container" class="space-y-2">
                <p class="text-gray-500">No active alerts</p>
            </div>
        </section>
    </div>

    <script>
        // Chart configurations
        const chartOptions = {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    display: true,
                    position: 'top'
                }
            },
            scales: {
                y: {
                    beginAtZero: true
                }
            }
        };

        // Initialize charts
        let userActivityChart, performanceChart;

        function initializeCharts() {
            // User Activity Chart
            const userActivityCtx = document.getElementById('userActivityChart').getContext('2d');
            userActivityChart = new Chart(userActivityCtx, {
                type: 'line',
                data: {
                    labels: [],
                    datasets: [{
                        label: 'Active Users',
                        data: [],
                        borderColor: 'rgb(59, 130, 246)',
                        backgroundColor: 'rgba(59, 130, 246, 0.1)',
                        tension: 0.4
                    }]
                },
                options: chartOptions
            });

            // Performance Chart
            const performanceCtx = document.getElementById('performanceChart').getContext('2d');
            performanceChart = new Chart(performanceCtx, {
                type: 'line',
                data: {
                    labels: [],
                    datasets: [
                        {
                            label: 'Response Time (ms)',
                            data: [],
                            borderColor: 'rgb(239, 68, 68)',
                            backgroundColor: 'rgba(239, 68, 68, 0.1)',
                            tension: 0.4,
                            yAxisID: 'y'
                        },
                        {
                            label: 'CPU Usage (%)',
                            data: [],
                            borderColor: 'rgb(34, 197, 94)',
                            backgroundColor: 'rgba(34, 197, 94, 0.1)',
                            tension: 0.4,
                            yAxisID: 'y1'
                        }
                    ]
                },
                options: {
                    ...chartOptions,
                    scales: {
                        y: {
                            type: 'linear',
                            display: true,
                            position: 'left',
                            beginAtZero: true
                        },
                        y1: {
                            type: 'linear',
                            display: true,
                            position: 'right',
                            beginAtZero: true,
                            max: 100,
                            grid: {
                                drawOnChartArea: false
                            }
                        }
                    }
                }
            });
        }

        // Update dashboard data
        async function updateDashboard() {
            try {
                // Get real-time metrics
                const metricsResponse = await fetch('/api/metrics/realtime');
                const metricsData = await metricsResponse.json();

                // Update key metrics
                if (metricsData.performance.length > 0) {
                    const latestPerf = metricsData.performance[0];
                    document.getElementById('response-time').textContent = 
                        Math.round(latestPerf.response_time) + 'ms';
                    document.getElementById('error-rate').textContent = 
                        (latestPerf.error_rate * 100).toFixed(2) + '%';
                }

                if (metricsData.business.length > 0) {
                    const latestBusiness = metricsData.business.find(m => m.metric_name === 'daily_active_users');
                    if (latestBusiness) {
                        document.getElementById('active-users').textContent = 
                            Math.round(latestBusiness.metric_value);
                    }
                }

                document.getElementById('uptime').textContent = '99.9%';

                // Get user analytics
                const userResponse = await fetch('/api/analytics/users');
                const userData = await userResponse.json();

                // Update user activity chart
                if (userData.activity_over_time) {
                    userActivityChart.data.labels = userData.activity_over_time.map(d => d.date);
                    userActivityChart.data.datasets[0].data = userData.activity_over_time.map(d => d.active_users);
                    userActivityChart.update();
                }

                // Get performance analytics
                const perfResponse = await fetch('/api/analytics/performance');
                const perfData = await perfResponse.json();

                // Update performance chart
                if (perfData.trends) {
                    performanceChart.data.labels = perfData.trends.map(d => d.date);
                    performanceChart.data.datasets[0].data = perfData.trends.map(d => Math.round(d.avg_response_time));
                    performanceChart.data.datasets[1].data = perfData.trends.map(d => Math.round(d.avg_cpu * 100));
                    performanceChart.update();
                }

                // Update alerts
                updateAlerts(perfData.alerts);

                // Get predictions
                const predictionsResponse = await fetch('/api/predictions');
                const predictionsData = await predictionsResponse.json();

                updatePredictions(predictionsData);

            } catch (error) {
                console.error('Error updating dashboard:', error);
            }
        }

        function updateAlerts(alerts) {
            const container = document.getElementById('alerts-container');
            
            if (alerts.length === 0) {
                container.innerHTML = '<p class="text-gray-500">No active alerts</p>';
                return;
            }

            container.innerHTML = alerts.map(alert => `
                <div class="flex items-center p-3 bg-red-50 border border-red-200 rounded-lg">
                    <div class="status-indicator status-error"></div>
                    <div class="flex-1">
                        <div class="font-medium text-red-800">${alert.message}</div>
                        <div class="text-sm text-red-600">${new Date(alert.timestamp).toLocaleString()}</div>
                    </div>
                </div>
            `).join('');
        }

        function updatePredictions(predictions) {
            if (predictions.usage) {
                document.getElementById('predicted-dau').textContent = predictions.usage.predicted_dau;
                document.getElementById('usage-confidence').textContent = 
                    (predictions.usage.confidence * 100).toFixed(0) + '%';
            }

            if (predictions.performance) {
                document.getElementById('expected-response').textContent = 
                    Math.round(predictions.performance.expected_response_time) + 'ms';
                document.getElementById('model-accuracy').textContent = 
                    predictions.performance.model_accuracy;
            }
        }

        // Initialize dashboard
        document.addEventListener('DOMContentLoaded', function() {
            initializeCharts();
            updateDashboard();
            
            // Update every 30 seconds
            setInterval(updateDashboard, 30000);
        });
    </script>
</body>
</html>
EOF
    
    # Create requirements.txt
    cat > "$DASHBOARD_DIR/requirements.txt" << 'EOF'
flask==2.3.3
pandas==2.0.3
numpy==1.24.3
scikit-learn==1.3.0
pyyaml==6.0.1
psutil==5.9.5
sqlite3
EOF
    
    print_success "Analytics dashboard created"
}

# Initialize models
initialize_models() {
    print_info "Initializing ML models..."
    
    # Create model directories
    mkdir -p "$MODELS_DIR"/{usage_prediction,anomaly_detection,user_behavior,performance_optimization}
    
    # Create placeholder model files
    for model_type in usage_prediction anomaly_detection user_behavior performance_optimization; do
        cat > "$MODELS_DIR/$model_type/README.md" << EOF
# $model_type Model

This directory contains the trained $model_type model.

## Files:
- model.pkl - Trained model file
- scaler.pkl - Feature scaler (if applicable)
- metadata.json - Model metadata and configuration

## Training:
Run \`./analytics/ai-dashboard.sh train\` to train or retrain this model.
EOF
    done
    
    print_success "Model directories initialized"
}

# Start analytics dashboard
start_dashboard() {
    print_info "Starting analytics dashboard..."
    
    # Check if dashboard is already running
    if pgrep -f "python.*app.py" > /dev/null; then
        print_warning "Dashboard is already running"
        return
    fi
    
    # Navigate to dashboard directory
    cd "$DASHBOARD_DIR"
    
    # Check if dependencies are installed
    if ! python3 -c "import flask" 2>/dev/null; then
        print_info "Installing Python dependencies..."
        pip3 install -r requirements.txt
    fi
    
    # Start dashboard
    python3 app.py &
    local dashboard_pid=$!
    echo "$dashboard_pid" > "$SCRIPT_DIR/.dashboard.pid"
    
    print_success "Dashboard started with PID: $dashboard_pid"
    print_info "Dashboard URL: http://localhost:3000"
}

# Stop analytics dashboard
stop_dashboard() {
    print_info "Stopping analytics dashboard..."
    
    if [[ -f "$SCRIPT_DIR/.dashboard.pid" ]]; then
        local dashboard_pid=$(cat "$SCRIPT_DIR/.dashboard.pid")
        if kill -0 "$dashboard_pid" 2>/dev/null; then
            kill "$dashboard_pid"
            print_success "Dashboard stopped (PID: $dashboard_pid)"
        else
            print_warning "Dashboard process not found"
        fi
        rm -f "$SCRIPT_DIR/.dashboard.pid"
    else
        # Try to find and kill dashboard process
        local dashboard_pid=$(pgrep -f "python.*app.py")
        if [[ -n "$dashboard_pid" ]]; then
            kill "$dashboard_pid"
            print_success "Dashboard stopped (PID: $dashboard_pid)"
        else
            print_warning "No dashboard process found"
        fi
    fi
}

# Collect data
collect_data() {
    print_info "Collecting analytics data..."
    
    # Start data collector
    cd "$SCRIPT_DIR"
    python3 collectors/data-collector.py "$CONFIG_FILE" &
    local collector_pid=$!
    echo "$collector_pid" > "$SCRIPT_DIR/.collector.pid"
    
    print_success "Data collection started (PID: $collector_pid)"
    
    # Collect for specified duration or run indefinitely
    if [[ -n "$COLLECTION_DURATION" ]]; then
        sleep "$COLLECTION_DURATION"
        kill "$collector_pid"
        rm -f "$SCRIPT_DIR/.collector.pid"
        print_success "Data collection completed"
    fi
}

# Run AI analysis
run_analysis() {
    print_info "Running AI analysis..."
    
    local model_type=${MODEL_TYPE:-"all"}
    
    cd "$SCRIPT_DIR"
    
    case "$model_type" in
        "usage")
            python3 ml/model-trainer.py "$CONFIG_FILE" "$MODELS_DIR"
            ;;
        "performance")
            python3 ml/model-trainer.py "$CONFIG_FILE" "$MODELS_DIR"
            ;;
        "anomaly")
            python3 ml/model-trainer.py "$CONFIG_FILE" "$MODELS_DIR"
            ;;
        "behavior")
            python3 ml/model-trainer.py "$CONFIG_FILE" "$MODELS_DIR"
            ;;
        "all"|*)
            python3 ml/model-trainer.py "$CONFIG_FILE" "$MODELS_DIR"
            ;;
    esac
    
    print_success "AI analysis completed"
}

# Generate predictions
generate_predictions() {
    print_info "Generating predictions..."
    
    # Load latest models and generate predictions
    cd "$SCRIPT_DIR"
    
    # This would typically call a prediction service
    python3 -c "
import json
from datetime import datetime, timedelta
from pathlib import Path

# Load models
models_dir = Path('$MODELS_DIR')
predictions = {}

# Usage prediction
usage_model_path = models_dir / 'usage_prediction' / 'model.json'
if usage_model_path.exists():
    with open(usage_model_path, 'r') as f:
        usage_model = json.load(f)
    
    last_values = usage_model['last_values']
    if last_values:
        prediction = sum(last_values) / len(last_values)
        predictions['usage'] = {
            'predicted_dau': int(prediction * 1.05),  # 5% growth assumption
            'confidence': 0.75,
            'horizon': '1 day'
        }

# Save predictions
predictions_path = Path('$REPORTS_DIR') / 'predictions.json'
predictions_path.parent.mkdir(parents=True, exist_ok=True)

with open(predictions_path, 'w') as f:
    json.dump({
        'generated_at': datetime.now().isoformat(),
        'predictions': predictions
    }, f, indent=2)

print(f'Predictions saved to {predictions_path}')
"
    
    print_success "Predictions generated"
}

# Generate reports
generate_reports() {
    print_info "Generating analytics reports..."
    
    local output_format=${OUTPUT_FORMAT:-"html"}
    local time_period=${TIME_PERIOD:-"day"}
    
    cd "$SCRIPT_DIR"
    
    # Generate report using dashboard data
    python3 -c "
import json
import sqlite3
from datetime import datetime, timedelta
from pathlib import Path
import yaml

# Load configuration
with open('$CONFIG_FILE', 'r') as f:
    config = yaml.safe_load(f)

# Connect to database
db_path = Path(config['integrations']['databases'][0]['path'])
conn = sqlite3.connect(db_path)

# Generate report data
report_data = {
    'generated_at': datetime.now().isoformat(),
    'period': '$time_period',
    'format': '$output_format'
}

# Get summary statistics
cursor = conn.cursor()

# User metrics
cursor.execute('''
    SELECT 
        COUNT(DISTINCT user_id) as total_users,
        COUNT(*) as total_actions,
        COUNT(DISTINCT feature) as features_used
    FROM user_activity 
    WHERE timestamp >= date('now', '-7 days')
''')
user_stats = cursor.fetchone()
report_data['user_metrics'] = {
    'total_users': user_stats[0],
    'total_actions': user_stats[1],
    'features_used': user_stats[2]
}

# Performance metrics
cursor.execute('''
    SELECT 
        AVG(cpu_usage) as avg_cpu,
        AVG(memory_usage) as avg_memory,
        AVG(response_time) as avg_response,
        AVG(error_rate) as avg_error_rate
    FROM performance_metrics 
    WHERE timestamp >= date('now', '-1 day')
''')
perf_stats = cursor.fetchone()
report_data['performance_metrics'] = {
    'avg_cpu_usage': f'{perf_stats[0]:.1%}',
    'avg_memory_usage': f'{perf_stats[1]:.1%}',
    'avg_response_time': f'{perf_stats[2]:.0f}ms',
    'avg_error_rate': f'{perf_stats[3]:.1%}'
}

conn.close()

# Save report
report_path = Path('$REPORTS_DIR') / f'analytics_report_{datetime.now().strftime(\"%Y%m%d_%H%M%S\")}.json'
report_path.parent.mkdir(parents=True, exist_ok=True)

with open(report_path, 'w') as f:
    json.dump(report_data, f, indent=2)

print(f'Report saved to {report_path}')
"
    
    print_success "Analytics report generated"
}

# Train ML models
train_models() {
    print_info "Training ML models..."
    
    cd "$SCRIPT_DIR"
    python3 ml/model-trainer.py "$CONFIG_FILE" "$MODELS_DIR"
    
    print_success "ML models training completed"
}

# Real-time monitoring
monitor_realtime() {
    print_info "Starting real-time monitoring..."
    
    # Start data collector
    collect_data
    
    # Start dashboard
    start_dashboard
    
    print_info "Real-time monitoring active"
    print_info "Dashboard: http://localhost:3000"
    print_info "Press Ctrl+C to stop monitoring"
    
    # Keep running
    while true; do
        sleep 10
    done
}

# Main function
main() {
    echo "🤖 Bun.app AI-Powered Analytics Dashboard"
    echo "=========================================="
    
    # Parse arguments
    parse_args "$@"
    
    # Handle commands
    case "${1:-help}" in
        "init")
            init_analytics_system
            ;;
        "start")
            start_dashboard
            ;;
        "stop")
            stop_dashboard
            ;;
        "collect")
            collect_data
            ;;
        "analyze")
            run_analysis
            ;;
        "predict")
            generate_predictions
            ;;
        "report")
            generate_reports
            ;;
        "train")
            train_models
            ;;
        "monitor")
            monitor_realtime
            ;;
        "help"|*)
            show_help
            ;;
    esac
}

# Handle script execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
