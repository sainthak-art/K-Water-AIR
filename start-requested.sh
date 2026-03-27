#!/bin/bash

# 환경변수 로딩
set -a
source ~/.env 2>/dev/null || source .env
set +a

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export SCRIPT_DIR

echo "요청하신 5개 서비스를 시작합니다..."

# 1. API Gateway
echo "1. API Gateway 시작 중..."
cd "$SCRIPT_DIR/api-gateway"
./mvnw spring-boot:run > /tmp/api-gateway.log 2>&1 &
echo "[✓] API Gateway 실행됨 (백그라운드)"

# 2. Robo Analyzer
echo "2. Robo Analyzer 시작 중..."
cd "$SCRIPT_DIR/robo-analyzer"
if [ ! -d ".venv" ]; then
  python3 -m venv .venv
fi
source .venv/bin/activate
pip install -q -r requirements.txt
uvicorn main:app --host 0.0.0.0 --port 5502 > /tmp/robo-analyzer.log 2>&1 &
echo "[✓] Robo Analyzer 실행됨 (백그라운드)"

# 3. Data Fabric (Backend & Frontend)
echo "3. Data Fabric 시작 중..."
cd "$SCRIPT_DIR/data-fabric/backend"
if [ ! -d "venv" ]; then
  python3 -m venv venv
fi
source venv/bin/activate
pip install -q -r requirements.txt
uvicorn app.main:app --host 0.0.0.0 --port 8000 > /tmp/data-fabric-backend.log 2>&1 &
cd "$SCRIPT_DIR/data-fabric/frontend"
npm install > /dev/null 2>&1
npm run dev > /tmp/data-fabric-frontend.log 2>&1 &
echo "[✓] Data Fabric (Backend & Frontend) 실행됨 (백그라운드)"

# 4. Domain Layer
echo "4. Domain Layer 시작 중..."
cd "$SCRIPT_DIR/domain-layer"
uv sync > /dev/null 2>&1
uv run python app/main.py > /tmp/domain-layer.log 2>&1 &
echo "[✓] Domain Layer 실행됨 (백그라운드)"

# 5. Robo Analyzer Vue3
echo "5. Robo Analyzer Vue3 시작 중..."
cd "$SCRIPT_DIR/robo-analyzer-vue3"
npm install > /dev/null 2>&1
npm run dev > /tmp/robo-analyzer-vue3.log 2>&1 &
echo "[✓] Robo Analyzer Vue3 실행됨 (백그라운드)"

echo ""
echo "========================================="
echo "✅ 요청하신 모든 서비스 실행 명령이 백그라운드에서 전달되었습니다."
echo "로그 확인 방법:"
echo "tail -f /tmp/api-gateway.log"
echo "tail -f /tmp/robo-analyzer.log"
echo "tail -f /tmp/data-fabric-backend.log"
echo "tail -f /tmp/domain-layer.log"
echo "tail -f /tmp/robo-analyzer-vue3.log"
echo "========================================="
