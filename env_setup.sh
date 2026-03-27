#!/bin/bash
# 이 스크립트를 실행(source)하면 .env 파일의 변수들이 현재 셸에 등록됩니다.
# 사용법: source env_setup.sh

set -a
source .env
set +a

echo "✅ 루트 .env 파일의 환경 변수가 성공적으로 등록되었습니다!"
