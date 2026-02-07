# Bolt's Journal - Critical Learnings

## 2025-01-24 - Pagination Loop Optimization

**Learning:** Reusing a base `httr2_request` object via `httr2::req_url_query()` in pagination loops significantly improves performance (~2.3x speedup) and reduces memory allocation (~225x reduction for 100 pages) compared to repeated full `octopus_api()` calls.

**Action:** Always refactor pagination loops to create a base request once and update only the necessary parameters (like `page`) in each iteration.

## 2025-01-24 - Mocking httr2 Requests

**Learning:** When refactoring code to use `httr2` functions like `req_url_query` on a request object, any mocks of API-calling functions must return a valid `httr2_request` object (not just a list) when `perform = FALSE` is used. Failure to do so will cause `httr2` type-checking to fail in tests.

**Action:** Ensure mocks for `octopus_api()` and similar functions return a real `httr2::request()` object when `perform = FALSE`. Use `httr2::url_parse()` in the parallel response mock to extract parameters from the resulting request URLs.
