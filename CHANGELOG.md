## 0.0.12
- Refactored Talker Interceptor to fix null issues
- ignored some file which should not be committed

## 0.0.11
- Update dependencies: talker to version 4.6.7 and rhttp to version 0.9.8


## 0.0.10
- Fix error message


## 0.0.9
- Refactor curl command generation to handle null JSON data

## 0.0.8
- Fixed a bug to handle null json request and response data

## 0.0.7
- Fix URL Bugs in response logs

## 0.0.6
- **Added Features:**
  - Introduced `RhttpLogs` and `RhttpCurlLog` classes for enhanced logging capabilities.
  - Added a curl command generator utility for easy curl command generation.

- **Fixes:**
  - Fixed issues related to response body printing for better accuracy and readability.

- **Enhancements:**
  - Improved curl setting for easy curl *printing*.

---

This update includes new classes and utilities to streamline logging and curl command generation, along with fixes to ensure accurate response body printing.

## 0.0.5
- Updated rhttp and talker dependencies to 0.9.3 and 4.5.1.


## 0.0.4

- Updated rhttp dependency from 0.8.1 to 0.9.1, and talker dependency from 4.4.1 to 4.4.7.
- Modified TalkerRhttpLogger to use migrated logCustom method(logTyped)


## 0.0.3

- fixes README.md


## 0.0.2

- Added status code messages map for better HTTP response interpretation
- Updated log messages for improved clarity and information
- Enhanced error handling in Rhttp logger
- Added headers to GET request logging
- Refactored log formatting for better readability
- Improved error handling in RhttpLoggerUi and RhttpLogs classes


## 0.0.1

🎉 Initial Release

- ✨ First public release
- 🚀 Core functionality implemented
- 📝 Basic documentation added