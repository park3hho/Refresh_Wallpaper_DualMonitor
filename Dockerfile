# Node.js LTS 이미지 사용
FROM node:18

# 컨테이너 작업 디렉토리 설정
WORKDIR /app

# package.json 복사
COPY package*.json ./

# 의존성 설치
RUN npm install

# 애플리케이션 복사
COPY . .

# 기본 실행 명령
CMD ["node", "src/index.js"]
