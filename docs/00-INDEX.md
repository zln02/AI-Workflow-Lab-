# AI Workflow Lab - Sonnet 작업 인덱스

## 작업 순서 (우선순위별)

| # | 파일 | 우선순위 | 내용 | 예상 난이도 |
|---|------|---------|------|-----------|
| 01 | `01-P0-SECURITY-FIXES.md` | **P0 긴급** | DB 비밀번호 하드코딩 제거, Session Fixation, XSS 취약점, CORS, planCode 불일치 | 보통 |
| 02 | `02-P1-RATE-LIMIT-AND-ERROR-PAGES.md` | **P1 높음** | Rate Limiting 필터, 404/500/403 에러 페이지 | 보통 |
| 03 | `03-P1-PAYMENT-INTEGRATION.md` | **P1 높음** | PortOne(아임포트) PG 결제 연동, checkout.jsp 구현, 결제 검증 | 어려움 |
| 04 | `04-P2-BACKEND-ARCHITECTURE.md` | **P2 중간** | API JSP->Servlet 마이그레이션, Service 레이어, 로깅 개선 | 보통 |
| 05 | `05-P1-HTTPS-NGINX-SETUP.md` | **P1 높음** | Nginx 리버스 프록시, Let's Encrypt SSL, 방화벽 | 보통 |
| 06 | `06-P2-MAVEN-AND-CICD.md` | **P2 중간** | Maven 빌드 시스템, Git 정리, GitHub Actions CI/CD | 보통 |
| 07 | `07-P3-FRONTEND-UX-AND-FEATURES.md` | **P3 낮음** | UX 개선, 이메일 인증, 비밀번호 찾기, 테스트 코드 | 보통 |

## 참고 문서
- `./AI-WORKFLOW-LAB-IMPROVEMENT-PLAN.md` - 전체 분석 리포트
- `./plans/STRATEGY.md` - 중장기 구현 전략
- `./guides/CLAUDE.md` - 작업/운영 가이드

## 프로젝트 정보
- **경로**: `/var/lib/tomcat9/webapps/ROOT/`
- **스택**: Java 11 + Tomcat 9 + MySQL + JSP/Servlet + Bootstrap 5
- **Git**: https://github.com/zln02/AI-Workflow-Lab-.git

## Sonnet 사용 시 공통 지침
1. 파일 수정 전 반드시 기존 파일을 먼저 읽을 것
2. Java 11 문법만 사용 (javax.servlet, jakarta 아님)
3. 모든 사용자 입력 출력 시 `EscapeUtil.escapeHtml()` 적용
4. SQL은 반드시 PreparedStatement 사용
5. Connection은 try-with-resources로 관리
6. 작업 완료 후 컴파일 명령어:
   ```bash
   cd /var/lib/tomcat9/webapps/ROOT
   javac -cp "WEB-INF/lib/*:/usr/share/tomcat9/lib/*" -d WEB-INF/classes $(find WEB-INF/src -name "*.java")
   sudo systemctl restart tomcat9
   ```
