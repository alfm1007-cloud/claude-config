# DB 테이블 구조 · RLS 정책

## reservations (예약)
```sql
id, requester_id, requester_name, guest_name, phone,
checkin, checkout, nights_count, room_count, guests,
hotel_name, room_types TEXT[], res_nums TEXT[], ref_nums TEXT[],
memo, status, amount, payment_status,
confirmed_by, sms_payment_status, sms_reservation_status,
sms_payment_log, sms_reservation_log,
custom_sms_pay, custom_sms_res,
hotel_suggestions JSONB, selected_hotel JSONB,
suggestion_read, suggestion_history JSONB DEFAULT '[]',
created_at, updated_at
```
**status 흐름:** pending → processing → requested → suggesting → confirmed → cancelled

## profiles (회원)
```sql
id UUID, name TEXT, role TEXT ('admin'|'sales'), created_at
```

## notifications (알림)
```sql
id BIGSERIAL, user_id UUID, type TEXT, reservation_id BIGINT,
title TEXT, description TEXT, is_read BOOLEAN, created_at
```
**type 값:** suggestion_request, suggestion, selected, rejected, new_request, sms_sent

## signup_requests (가입신청)
```sql
id, username, name, password_hash,
status (pending|approved|rejected),
requested_at, processed_at, processed_by
```

## push_subscriptions (Web Push 구독)
```sql
id, user_id UUID, subscription JSONB, created_at
UNIQUE(user_id)
```

## RLS 정책 현황
| 테이블 | 정책 |
|--------|------|
| reservations | 처리자 전체 / 신청자 본인만 |
| profiles | 전체 조회 허용 |
| notifications | 본인 조회 + DELETE 정책 필수 |
| signup_requests | INSERT 누구나 / SELECT·UPDATE 처리자만 |
| push_subscriptions | SELECT·INSERT·UPDATE 본인만 (정책 3개 분리 필수) |

⚠️ push_subscriptions에 단일 ALL 정책 금지 — SELECT/INSERT/UPDATE 각각 분리해야 함.
