#include-once

; Added For Lili
Global $post_data="" , $HTTP_POST_BOUNDARY="ABCDEFABCDEFFEDLDJKZSDLILI"

Func InitPostData()
	$post_data = "--" & $HTTP_POST_BOUNDARY & @CRLF
EndFunc

Func AddPostData($content_name,$content)
	$post_data &= 'Content-Disposition: form-data; name="'& $content_name&'"' & @CRLF & @CRLF & _
	$content & @CRLF & "--"&$HTTP_POST_BOUNDARY & @CRLF
EndFunc

Func ClosePostData()
	$post_data &= "--"& @CRLF
EndFunc


Global Const $INTERNET_DEFAULT_PORT = 0
Global Const $INTERNET_DEFAULT_HTTP_PORT = 80
Global Const $INTERNET_DEFAULT_HTTPS_PORT = 443

Global Const $INTERNET_SCHEME_HTTP = 1
Global Const $INTERNET_SCHEME_HTTPS = 2

Global Const $ICU_ESCAPE = 0x80000000

; For WinHttpOpen
Global Const $WINHTTP_FLAG_ASYNC = 0x10000000

; For WinHttpOpenRequest  ;
Global Const $WINHTTP_FLAG_ESCAPE_PERCENT = 0x00000004
Global Const $WINHTTP_FLAG_NULL_CODEPAGE = 0x00000008
Global Const $WINHTTP_FLAG_ESCAPE_DISABLE = 0x00000040
Global Const $WINHTTP_FLAG_ESCAPE_DISABLE_QUERY = 0x00000080
Global Const $WINHTTP_FLAG_BYPASS_PROXY_CACHE = 0x00000100
Global Const $WINHTTP_FLAG_REFRESH = $WINHTTP_FLAG_BYPASS_PROXY_CACHE
Global Const $WINHTTP_FLAG_SECURE = 0x00800000

Global Const $WINHTTP_ACCESS_TYPE_DEFAULT_PROXY = 0
Global Const $WINHTTP_ACCESS_TYPE_NO_PROXY = 1
Global Const $WINHTTP_ACCESS_TYPE_NAMED_PROXY = 3

Global Const $WINHTTP_NO_PROXY_NAME = ""
Global Const $WINHTTP_NO_PROXY_BYPASS = ""

Global Const $WINHTTP_NO_REFERER = ""
Global Const $WINHTTP_DEFAULT_ACCEPT_TYPES = ""

Global Const $WINHTTP_NO_ADDITIONAL_HEADERS = ""
Global Const $WINHTTP_NO_REQUEST_DATA = ""

Global Const $WINHTTP_HEADER_NAME_BY_INDEX = ""
Global Const $WINHTTP_NO_OUTPUT_BUFFER = 0
Global Const $WINHTTP_NO_HEADER_INDEX = 0

Global Const $WINHTTP_ADDREQ_INDEX_MASK = 0x0000FFFF
Global Const $WINHTTP_ADDREQ_FLAGS_MASK = 0xFFFF0000
Global Const $WINHTTP_ADDREQ_FLAG_ADD_IF_NEW = 0x10000000
Global Const $WINHTTP_ADDREQ_FLAG_ADD = 0x20000000
Global Const $WINHTTP_ADDREQ_FLAG_COALESCE_WITH_COMMA = 0x40000000
Global Const $WINHTTP_ADDREQ_FLAG_COALESCE_WITH_SEMICOLON = 0x01000000
Global Const $WINHTTP_ADDREQ_FLAG_COALESCE = $WINHTTP_ADDREQ_FLAG_COALESCE_WITH_COMMA
Global Const $WINHTTP_ADDREQ_FLAG_REPLACE = 0x80000000

Global Const $WINHTTP_IGNORE_REQUEST_TOTAL_LENGTH = 0

; For WinHttp{Set and Query} Options  ;
Global Const $WINHTTP_OPTION_CALLBACK = 1
Global Const $WINHTTP_FIRST_OPTION = $WINHTTP_OPTION_CALLBACK
Global Const $WINHTTP_OPTION_RESOLVE_TIMEOUT = 2
Global Const $WINHTTP_OPTION_CONNECT_TIMEOUT = 3
Global Const $WINHTTP_OPTION_CONNECT_RETRIES = 4
Global Const $WINHTTP_OPTION_SEND_TIMEOUT = 5
Global Const $WINHTTP_OPTION_RECEIVE_TIMEOUT = 6
Global Const $WINHTTP_OPTION_RECEIVE_RESPONSE_TIMEOUT = 7
Global Const $WINHTTP_OPTION_HANDLE_TYPE = 9
Global Const $WINHTTP_OPTION_READ_BUFFER_SIZE = 12
Global Const $WINHTTP_OPTION_WRITE_BUFFER_SIZE = 13
Global Const $WINHTTP_OPTION_PARENT_HANDLE = 21
Global Const $WINHTTP_OPTION_EXTENDED_ERROR = 24
Global Const $WINHTTP_OPTION_SECURITY_FLAGS = 31
Global Const $WINHTTP_OPTION_SECURITY_CERTIFICATE_STRUCT = 32
Global Const $WINHTTP_OPTION_URL = 34
Global Const $WINHTTP_OPTION_SECURITY_KEY_BITNESS = 36
Global Const $WINHTTP_OPTION_PROXY = 38
Global Const $WINHTTP_OPTION_USER_AGENT = 41
Global Const $WINHTTP_OPTION_CONTEXT_VALUE = 45
Global Const $WINHTTP_OPTION_CLIENT_CERT_CONTEXT = 47
Global Const $WINHTTP_OPTION_REQUEST_PRIORITY = 58
Global Const $WINHTTP_OPTION_HTTP_VERSION = 59
Global Const $WINHTTP_OPTION_DISABLE_FEATURE = 63
Global Const $WINHTTP_OPTION_CODEPAGE = 68
Global Const $WINHTTP_OPTION_MAX_CONNS_PER_SERVER = 73
Global Const $WINHTTP_OPTION_MAX_CONNS_PER_1_0_SERVER = 74
Global Const $WINHTTP_OPTION_AUTOLOGON_POLICY = 77
Global Const $WINHTTP_OPTION_SERVER_CERT_CONTEXT = 78
Global Const $WINHTTP_OPTION_ENABLE_FEATURE = 79
Global Const $WINHTTP_OPTION_WORKER_THREAD_COUNT = 80
Global Const $WINHTTP_OPTION_PASSPORT_COBRANDING_TEXT = 81
Global Const $WINHTTP_OPTION_PASSPORT_COBRANDING_URL = 82
Global Const $WINHTTP_OPTION_CONFIGURE_PASSPORT_AUTH = 83
Global Const $WINHTTP_OPTION_SECURE_PROTOCOLS = 84
Global Const $WINHTTP_OPTION_ENABLETRACING = 85
Global Const $WINHTTP_OPTION_PASSPORT_SIGN_OUT = 86
Global Const $WINHTTP_OPTION_PASSPORT_RETURN_URL = 87
Global Const $WINHTTP_OPTION_REDIRECT_POLICY = 88
Global Const $WINHTTP_OPTION_MAX_HTTP_AUTOMATIC_REDIRECTS = 89
Global Const $WINHTTP_OPTION_MAX_HTTP_STATUS_CONTINUE = 90
Global Const $WINHTTP_OPTION_MAX_RESPONSE_HEADER_SIZE = 91
Global Const $WINHTTP_OPTION_MAX_RESPONSE_DRAIN_SIZE = 92
Global Const $WINHTTP_OPTION_CONNECTION_INFO = 93
Global Const $WINHTTP_OPTION_CLIENT_CERT_ISSUER_LIST = 94
Global Const $WINHTTP_OPTION_SPN = 96
Global Const $WINHTTP_OPTION_GLOBAL_PROXY_CREDS = 97
Global Const $WINHTTP_OPTION_GLOBAL_SERVER_CREDS = 98
Global Const $WINHTTP_OPTION_UNLOAD_NOTIFY_EVENT = 99
Global Const $WINHTTP_OPTION_REJECT_USERPWD_IN_URL = 100
Global Const $WINHTTP_OPTION_USE_GLOBAL_SERVER_CREDENTIALS = 101
Global Const $WINHTTP_LAST_OPTION = $WINHTTP_OPTION_USE_GLOBAL_SERVER_CREDENTIALS
Global Const $WINHTTP_OPTION_USERNAME = 0x1000
Global Const $WINHTTP_OPTION_PASSWORD = 0x1001
Global Const $WINHTTP_OPTION_PROXY_USERNAME = 0x1002
Global Const $WINHTTP_OPTION_PROXY_PASSWORD = 0x1003

Global Const $WINHTTP_CONNS_PER_SERVER_UNLIMITED = 0xFFFFFFFF

Global Const $WINHTTP_AUTOLOGON_SECURITY_LEVEL_MEDIUM = 0
Global Const $WINHTTP_AUTOLOGON_SECURITY_LEVEL_LOW = 1
Global Const $WINHTTP_AUTOLOGON_SECURITY_LEVEL_HIGH = 2
Global Const $WINHTTP_AUTOLOGON_SECURITY_LEVEL_DEFAULT = $WINHTTP_AUTOLOGON_SECURITY_LEVEL_MEDIUM

Global Const $WINHTTP_OPTION_REDIRECT_POLICY_NEVER = 0
Global Const $WINHTTP_OPTION_REDIRECT_POLICY_DISALLOW_HTTPS_TO_HTTP = 1
Global Const $WINHTTP_OPTION_REDIRECT_POLICY_ALWAYS = 2
Global Const $WINHTTP_OPTION_REDIRECT_POLICY_LAST = $WINHTTP_OPTION_REDIRECT_POLICY_ALWAYS
Global Const $WINHTTP_OPTION_REDIRECT_POLICY_DEFAULT = $WINHTTP_OPTION_REDIRECT_POLICY_DISALLOW_HTTPS_TO_HTTP

Global Const $WINHTTP_DISABLE_PASSPORT_AUTH = 0x00000000
Global Const $WINHTTP_ENABLE_PASSPORT_AUTH = 0x10000000
Global Const $WINHTTP_DISABLE_PASSPORT_KEYRING = 0x20000000
Global Const $WINHTTP_ENABLE_PASSPORT_KEYRING = 0x40000000

Global Const $WINHTTP_DISABLE_COOKIES = 0x00000001
Global Const $WINHTTP_DISABLE_REDIRECTS = 0x00000002
Global Const $WINHTTP_DISABLE_AUTHENTICATION = 0x00000004
Global Const $WINHTTP_DISABLE_KEEP_ALIVE = 0x00000008
Global Const $WINHTTP_ENABLE_SSL_REVOCATION = 0x00000001
Global Const $WINHTTP_ENABLE_SSL_REVERT_IMPERSONATION = 0x00000002
Global Const $WINHTTP_DISABLE_SPN_SERVER_PORT = 0x00000000
Global Const $WINHTTP_ENABLE_SPN_SERVER_PORT = 0x00000001
Global Const $WINHTTP_OPTION_SPN_MASK = $WINHTTP_ENABLE_SPN_SERVER_PORT

; WinHTTP error codes  ;
Global Const $WINHTTP_ERROR_BASE = 12000
Global Const $ERROR_WINHTTP_OUT_OF_HANDLES = 12001
Global Const $ERROR_WINHTTP_TIMEOUT = 12002
Global Const $ERROR_WINHTTP_INTERNAL_ERROR = 12004
Global Const $ERROR_WINHTTP_INVALID_URL = 12005
Global Const $ERROR_WINHTTP_UNRECOGNIZED_SCHEME = 12006
Global Const $ERROR_WINHTTP_NAME_NOT_RESOLVED = 12007
Global Const $ERROR_WINHTTP_INVALID_OPTION = 12009
Global Const $ERROR_WINHTTP_OPTION_NOT_SETTABLE = 12011
Global Const $ERROR_WINHTTP_SHUTDOWN = 12012
Global Const $ERROR_WINHTTP_LOGIN_FAILURE = 12015
Global Const $ERROR_WINHTTP_OPERATION_CANCELLED = 12017
Global Const $ERROR_WINHTTP_INCORRECT_HANDLE_TYPE = 12018
Global Const $ERROR_WINHTTP_INCORRECT_HANDLE_STATE = 12019
Global Const $ERROR_WINHTTP_CANNOT_CONNECT = 12029
Global Const $ERROR_WINHTTP_CONNECTION_ERROR = 12030
Global Const $ERROR_WINHTTP_RESEND_REQUEST = 12032
Global Const $ERROR_WINHTTP_SECURE_CERT_DATE_INVALID = 12037
Global Const $ERROR_WINHTTP_SECURE_CERT_CN_INVALID = 12038
Global Const $ERROR_WINHTTP_CLIENT_AUTH_CERT_NEEDED = 12044
Global Const $ERROR_WINHTTP_SECURE_INVALID_CA = 12045
Global Const $ERROR_WINHTTP_SECURE_CERT_REV_FAILED = 12057
Global Const $ERROR_WINHTTP_CANNOT_CALL_BEFORE_OPEN = 12100
Global Const $ERROR_WINHTTP_CANNOT_CALL_BEFORE_SEND = 12101
Global Const $ERROR_WINHTTP_CANNOT_CALL_AFTER_SEND = 12102
Global Const $ERROR_WINHTTP_CANNOT_CALL_AFTER_OPEN = 12103
Global Const $ERROR_WINHTTP_HEADER_NOT_FOUND = 12150
Global Const $ERROR_WINHTTP_INVALID_SERVER_RESPONSE = 12152
Global Const $ERROR_WINHTTP_INVALID_HEADER = 12153
Global Const $ERROR_WINHTTP_INVALID_QUERY_REQUEST = 12154
Global Const $ERROR_WINHTTP_HEADER_ALREADY_EXISTS = 12155
Global Const $ERROR_WINHTTP_REDIRECT_FAILED = 12156
Global Const $ERROR_WINHTTP_SECURE_CHANNEL_ERROR = 12157
Global Const $ERROR_WINHTTP_BAD_AUTO_PROXY_SCRIPT = 12166
Global Const $ERROR_WINHTTP_UNABLE_TO_DOWNLOAD_SCRIPT = 12167
Global Const $ERROR_WINHTTP_SECURE_INVALID_CERT = 12169
Global Const $ERROR_WINHTTP_SECURE_CERT_REVOKED = 12170
Global Const $ERROR_WINHTTP_NOT_INITIALIZED = 12172
Global Const $ERROR_WINHTTP_SECURE_FAILURE = 12175
Global Const $ERROR_WINHTTP_AUTO_PROXY_SERVICE_ERROR = 12178
Global Const $ERROR_WINHTTP_SECURE_CERT_WRONG_USAGE = 12179
Global Const $ERROR_WINHTTP_AUTODETECTION_FAILED = 12180
Global Const $ERROR_WINHTTP_HEADER_COUNT_EXCEEDED = 12181
Global Const $ERROR_WINHTTP_HEADER_SIZE_OVERFLOW = 12182
Global Const $ERROR_WINHTTP_CHUNKED_ENCODING_HEADER_SIZE_OVERFLOW = 12183
Global Const $ERROR_WINHTTP_RESPONSE_DRAIN_OVERFLOW = 12184
Global Const $ERROR_WINHTTP_CLIENT_CERT_NO_PRIVATE_KEY = 12185
Global Const $ERROR_WINHTTP_CLIENT_CERT_NO_ACCESS_PRIVATE_KEY = 12186
Global Const $WINHTTP_ERROR_LAST = 12186

; WinHttp status codes  ;
Global Const $HTTP_STATUS_CONTINUE = 100
Global Const $HTTP_STATUS_SWITCH_PROTOCOLS = 101
Global Const $HTTP_STATUS_OK = 200
Global Const $HTTP_STATUS_CREATED = 201
Global Const $HTTP_STATUS_ACCEPTED = 202
Global Const $HTTP_STATUS_PARTIAL = 203
Global Const $HTTP_STATUS_NO_CONTENT = 204
Global Const $HTTP_STATUS_RESET_CONTENT = 205
Global Const $HTTP_STATUS_PARTIAL_CONTENT = 206
Global Const $HTTP_STATUS_WEBDAV_MULTI_STATUS = 207
Global Const $HTTP_STATUS_AMBIGUOUS = 300
Global Const $HTTP_STATUS_MOVED = 301
Global Const $HTTP_STATUS_REDIRECT = 302
Global Const $HTTP_STATUS_REDIRECT_METHOD = 303
Global Const $HTTP_STATUS_NOT_MODIFIED = 304
Global Const $HTTP_STATUS_USE_PROXY = 305
Global Const $HTTP_STATUS_REDIRECT_KEEP_VERB = 307
Global Const $HTTP_STATUS_BAD_REQUEST = 400
Global Const $HTTP_STATUS_DENIED = 401
Global Const $HTTP_STATUS_PAYMENT_REQ = 402
Global Const $HTTP_STATUS_FORBIDDEN = 403
Global Const $HTTP_STATUS_NOT_FOUND = 404
Global Const $HTTP_STATUS_BAD_METHOD = 405
Global Const $HTTP_STATUS_NONE_ACCEPTABLE = 406
Global Const $HTTP_STATUS_PROXY_AUTH_REQ = 407
Global Const $HTTP_STATUS_REQUEST_TIMEOUT = 408
Global Const $HTTP_STATUS_CONFLICT = 409
Global Const $HTTP_STATUS_GONE = 410
Global Const $HTTP_STATUS_LENGTH_REQUIRED = 411
Global Const $HTTP_STATUS_PRECOND_FAILED = 412
Global Const $HTTP_STATUS_REQUEST_TOO_LARGE = 413
Global Const $HTTP_STATUS_URI_TOO_LONG = 414
Global Const $HTTP_STATUS_UNSUPPORTED_MEDIA = 415
Global Const $HTTP_STATUS_RETRY_WITH = 449
Global Const $HTTP_STATUS_SERVER_ERROR = 500
Global Const $HTTP_STATUS_NOT_SUPPORTED = 501
Global Const $HTTP_STATUS_BAD_GATEWAY = 502
Global Const $HTTP_STATUS_SERVICE_UNAVAIL = 503
Global Const $HTTP_STATUS_GATEWAY_TIMEOUT = 504
Global Const $HTTP_STATUS_VERSION_NOT_SUP = 505
Global Const $HTTP_STATUS_FIRST = $HTTP_STATUS_CONTINUE
Global Const $HTTP_STATUS_LAST = $HTTP_STATUS_VERSION_NOT_SUP

Global Const $SECURITY_FLAG_IGNORE_UNKNOWN_CA = 0x00000100
Global Const $SECURITY_FLAG_IGNORE_CERT_DATE_INVALID = 0x00002000
Global Const $SECURITY_FLAG_IGNORE_CERT_CN_INVALID = 0x00001000
Global Const $SECURITY_FLAG_IGNORE_CERT_WRONG_USAGE = 0x00000200
Global Const $SECURITY_FLAG_SECURE = 0x00000001
Global Const $SECURITY_FLAG_STRENGTH_WEAK = 0x10000000
Global Const $SECURITY_FLAG_STRENGTH_MEDIUM = 0x40000000
Global Const $SECURITY_FLAG_STRENGTH_STRONG = 0x20000000

Global Const $ICU_NO_ENCODE = 0x20000000
Global Const $ICU_DECODE = 0x10000000
Global Const $ICU_NO_META = 0x08000000
Global Const $ICU_ENCODE_SPACES_ONLY = 0x04000000
Global Const $ICU_BROWSER_MODE = 0x02000000
Global Const $ICU_ENCODE_PERCENT = 0x00001000

; Query flags  ;
Global Const $WINHTTP_QUERY_MIME_VERSION = 0
Global Const $WINHTTP_QUERY_CONTENT_TYPE = 1
Global Const $WINHTTP_QUERY_CONTENT_TRANSFER_ENCODING = 2
Global Const $WINHTTP_QUERY_CONTENT_ID = 3
Global Const $WINHTTP_QUERY_CONTENT_DESCRIPTION = 4
Global Const $WINHTTP_QUERY_CONTENT_LENGTH = 5
Global Const $WINHTTP_QUERY_CONTENT_LANGUAGE = 6
Global Const $WINHTTP_QUERY_ALLOW = 7
Global Const $WINHTTP_QUERY_PUBLIC = 8
Global Const $WINHTTP_QUERY_DATE = 9
Global Const $WINHTTP_QUERY_EXPIRES = 10
Global Const $WINHTTP_QUERY_LAST_MODIFIED = 11
Global Const $WINHTTP_QUERY_MESSAGE_ID = 12
Global Const $WINHTTP_QUERY_URI = 13
Global Const $WINHTTP_QUERY_DERIVED_FROM = 14
Global Const $WINHTTP_QUERY_COST = 15
Global Const $WINHTTP_QUERY_LINK = 16
Global Const $WINHTTP_QUERY_PRAGMA = 17
Global Const $WINHTTP_QUERY_VERSION = 18
Global Const $WINHTTP_QUERY_STATUS_CODE = 19
Global Const $WINHTTP_QUERY_STATUS_TEXT = 20
Global Const $WINHTTP_QUERY_RAW_HEADERS = 21
Global Const $WINHTTP_QUERY_RAW_HEADERS_CRLF = 22
Global Const $WINHTTP_QUERY_CONNECTION = 23
Global Const $WINHTTP_QUERY_ACCEPT = 24
Global Const $WINHTTP_QUERY_ACCEPT_CHARSET = 25
Global Const $WINHTTP_QUERY_ACCEPT_ENCODING = 26
Global Const $WINHTTP_QUERY_ACCEPT_LANGUAGE = 27
Global Const $WINHTTP_QUERY_AUTHORIZATION = 28
Global Const $WINHTTP_QUERY_CONTENT_ENCODING = 29
Global Const $WINHTTP_QUERY_FORWARDED = 30
Global Const $WINHTTP_QUERY_FROM = 31
Global Const $WINHTTP_QUERY_IF_MODIFIED_SINCE = 32
Global Const $WINHTTP_QUERY_LOCATION = 33
Global Const $WINHTTP_QUERY_ORIG_URI = 34
Global Const $WINHTTP_QUERY_REFERER = 35
Global Const $WINHTTP_QUERY_RETRY_AFTER = 36
Global Const $WINHTTP_QUERY_SERVER = 37
Global Const $WINHTTP_QUERY_TITLE = 38
Global Const $WINHTTP_QUERY_USER_AGENT = 39
Global Const $WINHTTP_QUERY_WWW_AUTHENTICATE = 40
Global Const $WINHTTP_QUERY_PROXY_AUTHENTICATE = 41
Global Const $WINHTTP_QUERY_ACCEPT_RANGES = 42
Global Const $WINHTTP_QUERY_SET_COOKIE = 43
Global Const $WINHTTP_QUERY_COOKIE = 44
Global Const $WINHTTP_QUERY_REQUEST_METHOD = 45
Global Const $WINHTTP_QUERY_REFRESH = 46
Global Const $WINHTTP_QUERY_CONTENT_DISPOSITION = 47
Global Const $WINHTTP_QUERY_AGE = 48
Global Const $WINHTTP_QUERY_CACHE_CONTROL = 49
Global Const $WINHTTP_QUERY_CONTENT_BASE = 50
Global Const $WINHTTP_QUERY_CONTENT_LOCATION = 51
Global Const $WINHTTP_QUERY_CONTENT_MD5 = 52
Global Const $WINHTTP_QUERY_CONTENT_RANGE = 53
Global Const $WINHTTP_QUERY_ETAG = 54
Global Const $WINHTTP_QUERY_HOST = 55
Global Const $WINHTTP_QUERY_IF_MATCH = 56
Global Const $WINHTTP_QUERY_IF_NONE_MATCH = 57
Global Const $WINHTTP_QUERY_IF_RANGE = 58
Global Const $WINHTTP_QUERY_IF_UNMODIFIED_SINCE = 59
Global Const $WINHTTP_QUERY_MAX_FORWARDS = 60
Global Const $WINHTTP_QUERY_PROXY_AUTHORIZATION = 61
Global Const $WINHTTP_QUERY_RANGE = 62
Global Const $WINHTTP_QUERY_TRANSFER_ENCODING = 63
Global Const $WINHTTP_QUERY_UPGRADE = 64
Global Const $WINHTTP_QUERY_VARY = 65
Global Const $WINHTTP_QUERY_VIA = 66
Global Const $WINHTTP_QUERY_WARNING = 67
Global Const $WINHTTP_QUERY_EXPECT = 68
Global Const $WINHTTP_QUERY_PROXY_CONNECTION = 69
Global Const $WINHTTP_QUERY_UNLESS_MODIFIED_SINCE = 70
Global Const $WINHTTP_QUERY_PROXY_SUPPORT = 75
Global Const $WINHTTP_QUERY_AUTHENTICATION_INFO = 76
Global Const $WINHTTP_QUERY_PASSPORT_URLS = 77
Global Const $WINHTTP_QUERY_PASSPORT_CONFIG = 78
Global Const $WINHTTP_QUERY_MAX = 78
Global Const $WINHTTP_QUERY_CUSTOM = 65535
Global Const $WINHTTP_QUERY_FLAG_REQUEST_HEADERS = 0x80000000
Global Const $WINHTTP_QUERY_FLAG_SYSTEMTIME = 0x40000000
Global Const $WINHTTP_QUERY_FLAG_NUMBER = 0x20000000

; Callback options  ;
Global Const $WINHTTP_CALLBACK_STATUS_RESOLVING_NAME = 0x00000001
Global Const $WINHTTP_CALLBACK_STATUS_NAME_RESOLVED = 0x00000002
Global Const $WINHTTP_CALLBACK_STATUS_CONNECTING_TO_SERVER = 0x00000004
Global Const $WINHTTP_CALLBACK_STATUS_CONNECTED_TO_SERVER = 0x00000008
Global Const $WINHTTP_CALLBACK_STATUS_SENDING_REQUEST = 0x00000010
Global Const $WINHTTP_CALLBACK_STATUS_REQUEST_SENT = 0x00000020
Global Const $WINHTTP_CALLBACK_STATUS_RECEIVING_RESPONSE = 0x00000040
Global Const $WINHTTP_CALLBACK_STATUS_RESPONSE_RECEIVED = 0x00000080
Global Const $WINHTTP_CALLBACK_STATUS_CLOSING_CONNECTION = 0x00000100
Global Const $WINHTTP_CALLBACK_STATUS_CONNECTION_CLOSED = 0x00000200
Global Const $WINHTTP_CALLBACK_STATUS_HANDLE_CREATED = 0x00000400
Global Const $WINHTTP_CALLBACK_STATUS_HANDLE_CLOSING = 0x00000800
Global Const $WINHTTP_CALLBACK_STATUS_DETECTING_PROXY = 0x00001000
Global Const $WINHTTP_CALLBACK_STATUS_REDIRECT = 0x00004000
Global Const $WINHTTP_CALLBACK_STATUS_INTERMEDIATE_RESPONSE = 0x00008000
Global Const $WINHTTP_CALLBACK_STATUS_SECURE_FAILURE = 0x00010000
Global Const $WINHTTP_CALLBACK_STATUS_HEADERS_AVAILABLE = 0x00020000
Global Const $WINHTTP_CALLBACK_STATUS_DATA_AVAILABLE = 0x00040000
Global Const $WINHTTP_CALLBACK_STATUS_READ_COMPLETE = 0x00080000
Global Const $WINHTTP_CALLBACK_STATUS_WRITE_COMPLETE = 0x00100000
Global Const $WINHTTP_CALLBACK_STATUS_REQUEST_ERROR = 0x00200000
Global Const $WINHTTP_CALLBACK_STATUS_SENDREQUEST_COMPLETE = 0x00400000
Global Const $WINHTTP_CALLBACK_FLAG_RESOLVE_NAME = BitOR($WINHTTP_CALLBACK_STATUS_RESOLVING_NAME, $WINHTTP_CALLBACK_STATUS_NAME_RESOLVED)
Global Const $WINHTTP_CALLBACK_FLAG_CONNECT_TO_SERVER = BitOR($WINHTTP_CALLBACK_STATUS_CONNECTING_TO_SERVER, $WINHTTP_CALLBACK_STATUS_CONNECTED_TO_SERVER)
Global Const $WINHTTP_CALLBACK_FLAG_SEND_REQUEST = BitOR($WINHTTP_CALLBACK_STATUS_SENDING_REQUEST, $WINHTTP_CALLBACK_STATUS_REQUEST_SENT)
Global Const $WINHTTP_CALLBACK_FLAG_RECEIVE_RESPONSE = BitOR($WINHTTP_CALLBACK_STATUS_RECEIVING_RESPONSE, $WINHTTP_CALLBACK_STATUS_RESPONSE_RECEIVED)
Global Const $WINHTTP_CALLBACK_FLAG_CLOSE_CONNECTION = BitOR($WINHTTP_CALLBACK_STATUS_CLOSING_CONNECTION, $WINHTTP_CALLBACK_STATUS_CONNECTION_CLOSED)
Global Const $WINHTTP_CALLBACK_FLAG_HANDLES = BitOR($WINHTTP_CALLBACK_STATUS_HANDLE_CREATED, $WINHTTP_CALLBACK_STATUS_HANDLE_CLOSING)
Global Const $WINHTTP_CALLBACK_FLAG_DETECTING_PROXY = $WINHTTP_CALLBACK_STATUS_DETECTING_PROXY
Global Const $WINHTTP_CALLBACK_FLAG_REDIRECT = $WINHTTP_CALLBACK_STATUS_REDIRECT
Global Const $WINHTTP_CALLBACK_FLAG_INTERMEDIATE_RESPONSE = $WINHTTP_CALLBACK_STATUS_INTERMEDIATE_RESPONSE
Global Const $WINHTTP_CALLBACK_FLAG_SECURE_FAILURE = $WINHTTP_CALLBACK_STATUS_SECURE_FAILURE
Global Const $WINHTTP_CALLBACK_FLAG_SENDREQUEST_COMPLETE = $WINHTTP_CALLBACK_STATUS_SENDREQUEST_COMPLETE
Global Const $WINHTTP_CALLBACK_FLAG_HEADERS_AVAILABLE = $WINHTTP_CALLBACK_STATUS_HEADERS_AVAILABLE
Global Const $WINHTTP_CALLBACK_FLAG_DATA_AVAILABLE = $WINHTTP_CALLBACK_STATUS_DATA_AVAILABLE
Global Const $WINHTTP_CALLBACK_FLAG_READ_COMPLETE = $WINHTTP_CALLBACK_STATUS_READ_COMPLETE
Global Const $WINHTTP_CALLBACK_FLAG_WRITE_COMPLETE = $WINHTTP_CALLBACK_STATUS_WRITE_COMPLETE
Global Const $WINHTTP_CALLBACK_FLAG_REQUEST_ERROR = $WINHTTP_CALLBACK_STATUS_REQUEST_ERROR
Global Const $WINHTTP_CALLBACK_FLAG_ALL_COMPLETIONS = BitOR($WINHTTP_CALLBACK_STATUS_SENDREQUEST_COMPLETE, $WINHTTP_CALLBACK_STATUS_HEADERS_AVAILABLE, $WINHTTP_CALLBACK_STATUS_DATA_AVAILABLE, $WINHTTP_CALLBACK_STATUS_READ_COMPLETE, $WINHTTP_CALLBACK_STATUS_WRITE_COMPLETE, $WINHTTP_CALLBACK_STATUS_REQUEST_ERROR)
Global Const $WINHTTP_CALLBACK_FLAG_ALL_NOTIFICATIONS = 0xFFFFFFFF

Global Const $API_RECEIVE_RESPONSE = 1
Global Const $API_QUERY_DATA_AVAILABLE = 2
Global Const $API_READ_DATA = 3
Global Const $API_WRITE_DATA = 4
Global Const $API_SEND_REQUEST = 5

Global Const $WINHTTP_HANDLE_TYPE_SESSION = 1
Global Const $WINHTTP_HANDLE_TYPE_CONNECT = 2
Global Const $WINHTTP_HANDLE_TYPE_REQUEST = 3

Global Const $WINHTTP_CALLBACK_STATUS_FLAG_CERT_REV_FAILED = 0x00000001
Global Const $WINHTTP_CALLBACK_STATUS_FLAG_INVALID_CERT = 0x00000002
Global Const $WINHTTP_CALLBACK_STATUS_FLAG_CERT_REVOKED = 0x00000004
Global Const $WINHTTP_CALLBACK_STATUS_FLAG_INVALID_CA = 0x00000008
Global Const $WINHTTP_CALLBACK_STATUS_FLAG_CERT_CN_INVALID = 0x00000010
Global Const $WINHTTP_CALLBACK_STATUS_FLAG_CERT_DATE_INVALID = 0x00000020
Global Const $WINHTTP_CALLBACK_STATUS_FLAG_CERT_WRONG_USAGE = 0x00000040
Global Const $WINHTTP_CALLBACK_STATUS_FLAG_SECURITY_CHANNEL_ERROR = 0x80000000

Global Const $WINHTTP_AUTH_SCHEME_BASIC = 0x00000001
Global Const $WINHTTP_AUTH_SCHEME_NTLM = 0x00000002
Global Const $WINHTTP_AUTH_SCHEME_PASSPORT = 0x00000004
Global Const $WINHTTP_AUTH_SCHEME_DIGEST = 0x00000008
Global Const $WINHTTP_AUTH_SCHEME_NEGOTIATE = 0x00000010

Global Const $WINHTTP_AUTH_TARGET_SERVER = 0x00000000
Global Const $WINHTTP_AUTH_TARGET_PROXY = 0x00000001


Global Const $WINHTTP_AUTOPROXY_AUTO_DETECT = 0x00000001
Global Const $WINHTTP_AUTOPROXY_CONFIG_URL = 0x00000002
Global Const $WINHTTP_AUTOPROXY_RUN_INPROCESS = 0x00010000
Global Const $WINHTTP_AUTOPROXY_RUN_OUTPROCESS_ONLY = 0x00020000
Global Const $WINHTTP_AUTO_DETECT_TYPE_DHCP = 0x00000001
Global Const $WINHTTP_AUTO_DETECT_TYPE_DNS_A = 0x00000002

DllOpen("winhttp.dll")



; #FUNCTION# ;===============================================================================
;
; Name...........: _WinHttpAddRequestHeaders
; Description ...: Adds one or more HTTP request headers to the HTTP request handle.
; Syntax.........: _WinHttpAddRequestHeaders ($hRequest, $sHeaders [, $iModifiers])
; Parameters ....: $hRequest - Handle returned by _WinHttpOpenRequest function.
;                  $sHeader - String that contains the header(s) to append to the request.
;                  $iModifier - Contains the flags used to modify the semantics of this function. Default is $WINHTTP_ADDREQ_FLAG_ADD_IF_NEW.
; Return values .: Success - Returns 1 and Sets
;                          - Sets @error to 0
;                  Failure - Returns 0 and sets @error:
;                  |1 - DllCall failed.
; Author ........: trancexx
; Modified.......:
; Remarks .......: In case of multiple additions at once, must use @CRLF to separate each $hRequest and responded $sHeaders and $iModifiers.
; Related .......:
; Link ..........; http://msdn.microsoft.com/en-us/library/aa384087(VS.85).aspx
; Example .......; Yes
;
;==========================================================================================
Func _WinHttpAddRequestHeaders($hRequest, $sHeader, $iModifier = $WINHTTP_ADDREQ_FLAG_ADD_IF_NEW)

	Local $a_iCall = DllCall("winhttp.dll", "int", "WinHttpAddRequestHeaders", _
			"hwnd", $hRequest, _
			"wstr", $sHeader, _
			"dword", -1, _
			"dword", $iModifier)

	If @error Or Not $a_iCall[0] Then
		SetError(1, 0, 0)
	EndIf

	Return SetError(0, 0, 1)

EndFunc   ;==>_WinHttpAddRequestHeaders




; #FUNCTION# ;===============================================================================
;
; Name...........: _WinHttpBinaryConcat
; Description ...: Concatenates two binary data returned by _WinHttpReadData() in binary mode.
; Syntax.........: _WinHttpBinaryConcat(ByRef $bBinary1, ByRef $bBinary2)
; Parameters ....: $bBinary1 - Binary data that is to be concatenated.
;                  $bBinary2 - Binary data to concat.
; Return values .: Success - Returns concatenated binary data.
;                          - Sets @error to 0
;                  Failure - Returns 0 and sets @error:
;                  |1 - Invalid input.
; Author ........: ProgAndy
; Modified.......: trancexx
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......; Yes
;
;==========================================================================================
Func _WinHttpBinaryConcat(ByRef $bBinary1, ByRef $bBinary2)

	Switch IsBinary($bBinary1) + 2 * IsBinary($bBinary2)
		Case 0
			Return SetError(1, 0, 0)
		Case 1
			Return SetError(0, 0, $bBinary1)
		Case 2
			Return SetError(0, 0, $bBinary2)
	EndSwitch

	Local $tAuxiliary = DllStructCreate("byte[" & BinaryLen($bBinary1) & "];byte[" & BinaryLen($bBinary2) & "]")
	DllStructSetData($tAuxiliary, 1, $bBinary1)
	DllStructSetData($tAuxiliary, 2, $bBinary2)

	Local $tOutput = DllStructCreate("byte[" & DllStructGetSize($tAuxiliary) & "]", DllStructGetPtr($tAuxiliary))

	Return SetError(0, 0, DllStructGetData($tOutput, 1))

EndFunc   ;==>_WinHttpBinaryConcat




; #FUNCTION# ;===============================================================================
;
; Name...........: _WinHttpCheckPlatform
; Description ...: Determines whether the current platform is supported by this version of Microsoft Windows HTTP Services (WinHTTP).
; Syntax.........: _WinHttpCheckPlatform()
; Parameters ....: None
; Return values .: Success - Returns 1 if current platform is supported
;                          - Returns 0 if current platform is not supported
;                          - Sets @error to 0
;                  Failure - Returns 0 and sets @error:
;                  |1 - DllCall failed.
; Author ........: trancexx
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........; http://msdn.microsoft.com/en-us/library/aa384089(VS.85).aspx
; Example .......; Yes
;
;==========================================================================================
Func _WinHttpCheckPlatform()

	Local $a_iCall = DllCall("winhttp.dll", "int", "WinHttpCheckPlatform")

	If @error Then
		Return SetError(1, 0, 0)
	EndIf

	Return SetError(0, 0, $a_iCall[0])

EndFunc   ;==>_WinHttpCheckPlatform




; #FUNCTION# ;===============================================================================
;
; Name...........: _WinHttpCloseHandle
; Description ...: Closes a single handle.
; Syntax.........: _WinHttpCloseHandle($hInternet)
; Parameters ....: $hInternet - Valid handle to be closed.
; Return values .: Success - Returns 1
;                          - Sets @error to 0
;                  Failure - Returns 0 and sets @error:
;                  |1 - DllCall failed.
; Author ........: trancexx
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........; http://msdn.microsoft.com/en-us/library/aa384090(VS.85).aspx
; Example .......; Yes
;
;==========================================================================================
Func _WinHttpCloseHandle($hInternet)

	Local $a_iCall = DllCall("winhttp.dll", "int", "WinHttpCloseHandle", "hwnd", $hInternet)

	If @error Or Not $a_iCall[0] Then
		SetError(1, 0, 0)
	EndIf

	Return SetError(0, 0, 1)

EndFunc   ;==>_WinHttpCloseHandle




; #FUNCTION# ;===============================================================================
;
; Name...........: _WinHttpConnect
; Description ...: Specifies the initial target server of an HTTP request and returns connection handle to an HTTP session for that initial target.
; Syntax.........: _WinHttpConnect($hSession, $sServerName [, $iServerPort])
; Parameters ....: $hSession - Valid WinHTTP session handle returned by a previous call to WinHttpOpen.
;                  $sServerName - String that contains the host name of an HTTP server.
;                  $iServerPort - Integer that specifies the TCP/IP port on the server to which a connection is made (default is $INTERNET_DEFAULT_PORT)
; Return values .: Success - Returns a valid connection handle to the HTTP session
;                          - Sets @error to 0
;                  Failure - Returns 0 and sets @error:
;                  |1 - DllCall failed.
; Author ........: trancexx
; Modified.......:
; Remarks .......: $nServerPort can be defined via global constants $INTERNET_DEFAULT_PORT, $INTERNET_DEFAULT_HTTP_PORT or $INTERNET_DEFAULT_HTTPS_PORT
; Related .......:
; Link ..........; http://msdn.microsoft.com/en-us/library/aa384091(VS.85).aspx
; Example .......; Yes
;
;==========================================================================================
Func _WinHttpConnect($hSession, $sServerName, $iServerPort = $INTERNET_DEFAULT_PORT)

	Local $a_hCall = DllCall("winhttp.dll", "hwnd", "WinHttpConnect", _
			"hwnd", $hSession, _
			"wstr", $sServerName, _
			"dword", $iServerPort, _
			"dword", 0)

	If @error Or Not $a_hCall[0] Then
		Return SetError(1, 0, 0)
	EndIf

	Return SetError(0, 0, $a_hCall[0])

EndFunc   ;==>_WinHttpConnect




; #FUNCTION# ;===============================================================================
;
; Name...........: _WinHttpCrackUrl
; Description ...: Separates a URL into its component parts such as host name and path.
; Syntax.........: _WinHttpCrackUrl($sURL [, $iFlag])
; Parameters ....: $sURL - String that contains the canonical URL to separate.
;                  $dwFlag - Flag that control the operation. Default is $ICU_ESCAPE
; Return values .: Success - Returns array which first element [0] is scheme name,
;                                        second element [1] is internet protocol scheme.,
;                                        third element [2] is host name,
;                                        fourth element [3] is port number,
;                                        fifth element [4] is user name,
;                                        sixth element [5] is password,
;                                        seventh element [6] is URL path,
;                                        eighth element [7] is extra information.
;                          - Sets @error to 0
;                  Failure - Returns 0 and sets @error:
;                  |1 - DllCall failed.
; Author ........: ProgAndy
; Modified.......: trancexx
; Remarks .......: $dwFlag is defined in WinHTTPConstants.au3 and can be:
;                  | $ICU_DECODE - Converts characters that are "escape encoded" (%xx) to their non-escaped form.
;                  | $ICU_ESCAPE - Escapes certain characters to their escape sequences (%xx).
; Related .......:
; Link ..........; http://msdn.microsoft.com/en-us/library/aa384092(VS.85).aspx
; Example .......; Yes
;
;==========================================================================================
Func _WinHttpCrackUrl($sURL, $iFlag = $ICU_ESCAPE)

	Local $tURL_COMPONENTS = DllStructCreate("dword StructSize;" & _
			"ptr SchemeName;" & _
			"dword SchemeNameLength;" & _
			"int Scheme;" & _
			"ptr HostName;" & _
			"dword HostNameLength;" & _
			"ushort Port;" & _
			"ptr UserName;" & _
			"dword UserNameLength;" & _
			"ptr Password;" & _
			"dword PasswordLength;" & _
			"ptr UrlPath;" & _
			"dword UrlPathLength;" & _
			"ptr ExtraInfo;" & _
			"dword ExtraInfoLength")

	DllStructSetData($tURL_COMPONENTS, 1, DllStructGetSize($tURL_COMPONENTS))

	Local $tBuffers[6]
	Local $iURLLen = StringLen($sURL)

	For $i = 0 To 5
		$tBuffers[$i] = DllStructCreate("wchar[" & $iURLLen + 1 & "]")
	Next

	DllStructSetData($tURL_COMPONENTS, "SchemeNameLength", $iURLLen)
	DllStructSetData($tURL_COMPONENTS, "SchemeName", DllStructGetPtr($tBuffers[0]))
	DllStructSetData($tURL_COMPONENTS, "HostNameLength", $iURLLen)
	DllStructSetData($tURL_COMPONENTS, "HostName", DllStructGetPtr($tBuffers[1]))
	DllStructSetData($tURL_COMPONENTS, "UserNameLength", $iURLLen)
	DllStructSetData($tURL_COMPONENTS, "UserName", DllStructGetPtr($tBuffers[2]))
	DllStructSetData($tURL_COMPONENTS, "PasswordLength", $iURLLen)
	DllStructSetData($tURL_COMPONENTS, "Password", DllStructGetPtr($tBuffers[3]))
	DllStructSetData($tURL_COMPONENTS, "UrlPathLength", $iURLLen)
	DllStructSetData($tURL_COMPONENTS, "UrlPath", DllStructGetPtr($tBuffers[4]))
	DllStructSetData($tURL_COMPONENTS, "ExtraInfoLength", $iURLLen)
	DllStructSetData($tURL_COMPONENTS, "ExtraInfo", DllStructGetPtr($tBuffers[5]))

	Local $a_iCall = DllCall("winhttp.dll", "int", "WinHttpCrackUrl", _
			"wstr", $sURL, _
			"dword", $iURLLen, _
			"dword", $iFlag, _
			"ptr", DllStructGetPtr($tURL_COMPONENTS))

	If @error Or Not $a_iCall[0] Then
		Return SetError(1, 0, 0)
	EndIf

	Local $a_Ret[8] = [DllStructGetData($tBuffers[0], 1), _
			DllStructGetData($tURL_COMPONENTS, "Scheme"), _
			DllStructGetData($tBuffers[1], 1), _
			DllStructGetData($tURL_COMPONENTS, "Port"), _
			DllStructGetData($tBuffers[2], 1), _
			DllStructGetData($tBuffers[3], 1), _
			DllStructGetData($tBuffers[4], 1), _
			DllStructGetData($tBuffers[5], 1)]

	Return SetError(0, 0, $a_Ret)

EndFunc   ;==>_WinHttpCrackUrl




; #FUNCTION# ;===============================================================================
;
; Name...........: _WinHttpCreateUrl
; Description ...: Creates a URL from array of components such as the host name and path.
; Syntax.........: _WinHttpCreateUrl($aURLArray)
; Parameters ....: $sURL - String that contains the canonical URL to separate.
; Return values .: Success - Returns created URL
;                          - Sets @error to 0
;                  Failure - Returns 0 and sets @error:
;                  |1 - Invalid input.
;                  |2 - Initial DllCall failed.
;                  |3 - Main DllCall failed
; Author ........: ProgAndy
; Modified.......: trancexx
; Remarks .......: Input is one dimensional 8 elements in size array:
;                                        first element [0] is scheme name,
;                                        second element [1] is internet protocol scheme.,
;                                        third element [2] is host name,
;                                        fourth element [3] is port number,
;                                        fifth element [4] is user name,
;                                        sixth element [5] is password,
;                                        seventh element [6] is URL path,
;                                        eighth element [7] is extra information.
; Related .......:
; Link ..........; http://msdn.microsoft.com/en-us/library/aa384093(VS.85).aspx
; Example .......; Yes
;
;==========================================================================================
Func _WinHttpCreateUrl($aURLArray)

	If UBound($aURLArray) - 8 Then
		Return SetError(1, 0, "")
	EndIf

	Local $tURL_COMPONENTS = DllStructCreate("dword StructSize;" & _
			"ptr SchemeName;" & _
			"dword SchemeNameLength;" & _
			"int Scheme;" & _
			"ptr HostName;" & _
			"dword HostNameLength;" & _
			"ushort Port;" & _
			"ptr UserName;" & _
			"dword UserNameLength;" & _
			"ptr Password;" & _
			"dword PasswordLength;" & _
			"ptr UrlPath;" & _
			"dword UrlPathLength;" & _
			"ptr ExtraInfo;" & _
			"dword ExtraInfoLength;")

	DllStructSetData($tURL_COMPONENTS, 1, DllStructGetSize($tURL_COMPONENTS))

	Local $tBuffers[6][2]

	$tBuffers[0][1] = StringLen($aURLArray[0])
	If $tBuffers[0][1] Then
		$tBuffers[0][0] = DllStructCreate("wchar[" & $tBuffers[0][1] + 1 & "]")
		DllStructSetData($tBuffers[0][0], 1, $aURLArray[0])
	EndIf

	$tBuffers[1][1] = StringLen($aURLArray[2])
	If $tBuffers[1][1] Then
		$tBuffers[1][0] = DllStructCreate("wchar[" & $tBuffers[1][1] + 1 & "]")
		DllStructSetData($tBuffers[1][0], 1, $aURLArray[2])
	EndIf

	$tBuffers[2][1] = StringLen($aURLArray[4])
	If $tBuffers[2][1] Then
		$tBuffers[2][0] = DllStructCreate("wchar[" & $tBuffers[2][1] + 1 & "]")
		DllStructSetData($tBuffers[2][0], 1, $aURLArray[4])
	EndIf

	$tBuffers[3][1] = StringLen($aURLArray[5])
	If $tBuffers[3][1] Then
		$tBuffers[3][0] = DllStructCreate("wchar[" & $tBuffers[3][1] + 1 & "]")
		DllStructSetData($tBuffers[3][0], 1, $aURLArray[5])
	EndIf

	$tBuffers[4][1] = StringLen($aURLArray[6])
	If $tBuffers[4][1] Then
		$tBuffers[4][0] = DllStructCreate("wchar[" & $tBuffers[4][1] + 1 & "]")
		DllStructSetData($tBuffers[4][0], 1, $aURLArray[6])
	EndIf

	$tBuffers[5][1] = StringLen($aURLArray[7])
	If $tBuffers[5][1] Then
		$tBuffers[5][0] = DllStructCreate("wchar[" & $tBuffers[5][1] + 1 & "]")
		DllStructSetData($tBuffers[5][0], 1, $aURLArray[7])
	EndIf

	DllStructSetData($tURL_COMPONENTS, "SchemeNameLength", $tBuffers[0][1])
	DllStructSetData($tURL_COMPONENTS, "SchemeName", DllStructGetPtr($tBuffers[0][0]))
	DllStructSetData($tURL_COMPONENTS, "HostNameLength", $tBuffers[1][1])
	DllStructSetData($tURL_COMPONENTS, "HostName", DllStructGetPtr($tBuffers[1][0]))
	DllStructSetData($tURL_COMPONENTS, "UserNameLength", $tBuffers[2][1])
	DllStructSetData($tURL_COMPONENTS, "UserName", DllStructGetPtr($tBuffers[2][0]))
	DllStructSetData($tURL_COMPONENTS, "PasswordLength", $tBuffers[3][1])
	DllStructSetData($tURL_COMPONENTS, "Password", DllStructGetPtr($tBuffers[3][0]))
	DllStructSetData($tURL_COMPONENTS, "UrlPathLength", $tBuffers[4][1])
	DllStructSetData($tURL_COMPONENTS, "UrlPath", DllStructGetPtr($tBuffers[4][0]))
	DllStructSetData($tURL_COMPONENTS, "ExtraInfoLength", $tBuffers[5][1])
	DllStructSetData($tURL_COMPONENTS, "ExtraInfo", DllStructGetPtr($tBuffers[5][0]))

	DllStructSetData($tURL_COMPONENTS, "Scheme", $aURLArray[1])
	DllStructSetData($tURL_COMPONENTS, "Port", $aURLArray[3])

	Local $a_iCall = DllCall("winhttp.dll", "int", "WinHttpCreateUrl", _
			"ptr", DllStructGetPtr($tURL_COMPONENTS), _
			"dword", $ICU_ESCAPE, _
			"ptr", 0, _
			"dword*", 0)

	If @error Then
		Return SetError(2, 0, "")
	EndIf

	Local $iURLLen = $a_iCall[4]

	Local $URLBuffer = DllStructCreate("wchar[" & ($iURLLen + 1) & "]")

	$a_iCall = DllCall("winhttp.dll", "int", "WinHttpCreateUrl", _
			"ptr", DllStructGetPtr($tURL_COMPONENTS), _
			"dword", $ICU_ESCAPE, _
			"ptr", DllStructGetPtr($URLBuffer), _
			"dword*", $iURLLen)

	If @error Or Not $a_iCall[0] Then
		Return SetError(3, 0, "")
	EndIf

	Return SetError(0, 0, DllStructGetData($URLBuffer, 1))

EndFunc   ;==>_WinHttpCreateUrl




; #FUNCTION# ;===============================================================================
;
; Name...........: _WinHttpDetectAutoProxyConfigUrl
; Description ...: Finds the URL for the Proxy Auto-Configuration (PAC) file.
; Syntax.........: _WinHttpDetectAutoProxyConfigUrl($iAutoDetectFlags)
; Parameters ....: $iAutoDetectFlags - Specifies what protocols to use to locate the PAC file.
; Return values .: Success - Returns URL for the PAC file.
;                          - Sets @error to 0
;                  Failure - Returns empty string and sets @error:
;                  |1 - DllCall failed.
;                  |2 - Internal failure.
; Author ........: trancexx
; Modified.......:
; Remarks .......: $iAutoDetectFlags defined in WinHTTPconstants.au3
; Related .......:
; Link ..........; http://msdn.microsoft.com/en-us/library/aa384094(VS.85).aspx
; Example .......; Yes
;
;==========================================================================================
Func _WinHttpDetectAutoProxyConfigUrl($iAutoDetectFlags)

	Local $a_iCall = DllCall("winhttp.dll", "int", "WinHttpDetectAutoProxyConfigUrl", _
			"dword", $iAutoDetectFlags, _
			"ptr*", 0)

	If @error Or Not $a_iCall[0] Then
		Return SetError(1, 0, "")
	EndIf

	Local $pString = $a_iCall[2]

	If $pString Then
		Local $iLen = DllCall("kernel32.dll", "int", "lstrlenW", "ptr", $pString)
		If @error Then
			Return SetError(2, 0, "")
		EndIf
		Local $tString = DllStructCreate("wchar[" & $iLen[0] + 1 & "]", $pString)

		Return SetError(0, 0, DllStructGetData($tString, 1))
	EndIf

	Return SetError(0, 0, "")

EndFunc   ;==>_WinHttpDetectAutoProxyConfigUrl




; #FUNCTION# ;===============================================================================
;
; Name...........: _WinHttpGetDefaultProxyConfiguration
; Description ...: Retrieves the default WinHTTP proxy configuration.
; Syntax.........: _WinHttpGetDefaultProxyConfiguration()
; Parameters ....: None.
; Return values .: Success - Returns array which first element [0] is integer value that contains the access type,
;                                        second element [1] is string value that contains the proxy server list,
;                                        third element [2] is string value that contains the proxy bypass list.
;                          - Sets @error to 0
;                  Failure - Returns 0 and sets @error:
;                  |1 - DllCall failed.
;                  |2 - Internal failure.
; Author ........: trancexx
; Modified.......:
; Remarks .......: Access types are defined in WinHTTPconstants.au3:
;                  |$WINHTTP_ACCESS_TYPE_DEFAULT_PROXY = 0
;                  |$WINHTTP_ACCESS_TYPE_NO_PROXY = 1
;                  |$WINHTTP_ACCESS_TYPE_NAMED_PROXY = 3
; Related .......:
; Link ..........; http://msdn.microsoft.com/en-us/library/aa384095(VS.85).aspx
; Example .......; Yes
;
;==========================================================================================
Func _WinHttpGetDefaultProxyConfiguration()

	Local $tWINHTTP_PROXY_INFO = DllStructCreate("dword AccessType;" & _
			"ptr Proxy;" & _
			"ptr ProxyBypass")

	Local $a_iCall = DllCall("winhttp.dll", "int", "WinHttpGetDefaultProxyConfiguration", "ptr", DllStructGetPtr($tWINHTTP_PROXY_INFO))

	If @error Or Not $a_iCall[0] Then
		Return SetError(1, 0, 0)
	EndIf

	Local $aArray[3] = [DllStructGetData($tWINHTTP_PROXY_INFO, "AccessType"), _
			DllStructGetData($tWINHTTP_PROXY_INFO, "Proxy"), _
			DllStructGetData($tWINHTTP_PROXY_INFO, "ProxyBypass")]

	If $aArray[1] Then
		Local $iProxyLen = DllCall("kernel32.dll", "int", "lstrlenW", "ptr", $aArray[1])
		If @error Then
			Return SetError(2, 0, 0)
		EndIf
		Local $string_Proxy = DllStructCreate("wchar[" & $iProxyLen[0] + 1 & "]", $aArray[1])
		Local $Proxy = DllStructGetData($string_Proxy, 1)
	Else
		$Proxy = ""
	EndIf

	If $aArray[2] Then
		Local $iProxyBypassLen = DllCall("kernel32.dll", "int", "lstrlenW", "ptr", $aArray[2])
		If @error Then
			Return SetError(2, 0, 0)
		EndIf
		Local $string_ProxyBypass = DllStructCreate("wchar[" & $iProxyBypassLen[0] + 1 & "]", $aArray[2])
		Local $ProxyBypass = DllStructGetData($string_ProxyBypass, 1)
	Else
		$ProxyBypass = ""
	EndIf

	Local $a_Ret[3] = [$aArray[0], $Proxy, $ProxyBypass]

	Return SetError(0, 0, $a_Ret)

EndFunc   ;==>_WinHttpGetDefaultProxyConfiguration




; #FUNCTION# ;===============================================================================
;
; Name...........: _WinHttpGetIEProxyConfigForCurrentUser
; Description ...: Retrieves the Internet Explorer proxy configuration for the current user.
; Syntax.........: _WinHttpGetIEProxyConfigForCurrentUser()
; Parameters ....: None.
; Return values .: Success - Returns array which first element [0] if 1 indicates that the Internet Explorer proxy configuration for the current user specifies "automatically detect settings",
;                                        second element [1] is string that contains the auto-configuration URL if the Internet Explorer proxy configuration for the current user specifies "Use automatic proxy configuration",
;                                        third element [2] is string that contains the proxy URL if the Internet Explorer proxy configuration for the current user specifies "use a proxy server",
;                                        fourth element [3] is string that contains the optional proxy by-pass server list.
;                          - Sets @error to 0
;                  Failure - Returns 0 and sets @error:
;                  |1 - DllCall failed.
;                  |2 - Internal failure.
; Author ........: trancexx
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........; http://msdn.microsoft.com/en-us/library/aa384096(VS.85).aspx
; Example .......; Yes
;
;==========================================================================================
Func _WinHttpGetIEProxyConfigForCurrentUser()

	Local $tWINHTTP_CURRENT_USER_IE_PROXY_CONFIG = DllStructCreate("int AutoDetect;" & _
			"ptr AutoConfigUrl;" & _
			"ptr Proxy;" & _
			"ptr ProxyBypass;")

	Local $a_iCall = DllCall("winhttp.dll", "int", "WinHttpGetIEProxyConfigForCurrentUser", "ptr", DllStructGetPtr($tWINHTTP_CURRENT_USER_IE_PROXY_CONFIG))

	If @error Or Not $a_iCall[0] Then
		Return SetError(1, 0, 0)
	EndIf

	Local $aArray[4] = [DllStructGetData($tWINHTTP_CURRENT_USER_IE_PROXY_CONFIG, "AutoDetect"), _
			DllStructGetData($tWINHTTP_CURRENT_USER_IE_PROXY_CONFIG, "AutoConfigUrl"), _
			DllStructGetData($tWINHTTP_CURRENT_USER_IE_PROXY_CONFIG, "Proxy"), _
			DllStructGetData($tWINHTTP_CURRENT_USER_IE_PROXY_CONFIG, "ProxyBypass")]

	Local $sAutoConfigUrl
	If $aArray[1] Then
		Local $aAutoConfigUrlLen = DllCall("kernel32.dll", "int", "lstrlenW", "ptr", $aArray[1])
		If @error Then
			Return SetError(2, 0, 0)
		EndIf
		Local $tAutoConfigUrl = DllStructCreate("wchar[" & $aAutoConfigUrlLen[0] + 1 & "]", $aArray[1])
		$sAutoConfigUrl = DllStructGetData($tAutoConfigUrl, 1)
	Else
		$sAutoConfigUrl = ""
	EndIf

	Local $sProxy
	If $aArray[2] Then
		Local $aProxyLen = DllCall("kernel32.dll", "int", "lstrlenW", "ptr", $aArray[2])
		If @error Then
			Return SetError(2, 0, 0)
		EndIf
		Local $tProxy = DllStructCreate("wchar[" & $aProxyLen[0] + 1 & "]", $aArray[2])
		$sProxy = DllStructGetData($tProxy, 1)
	Else
		$sProxy = ""
	EndIf

	Local $sProxyBypass
	If $aArray[3] Then
		Local $aProxyBypassLen = DllCall("kernel32.dll", "int", "lstrlenW", "ptr", $aArray[3])
		If @error Then
			Return SetError(2, 0, 0)
		EndIf
		Local $tProxyBypass = DllStructCreate("wchar[" & $aProxyBypassLen[0] + 1 & "]", $aArray[3])
		$sProxyBypass = DllStructGetData($tProxyBypass, 1)
	Else
		$sProxyBypass = ""
	EndIf

	Local $aOutput[4] = [$aArray[0], $sAutoConfigUrl, $sProxy, $sProxyBypass]

	Return SetError(0, 0, $aOutput)

EndFunc   ;==>_WinHttpGetIEProxyConfigForCurrentUser




; #FUNCTION# ;===============================================================================
;
; Name...........: _WinHttpOpen
; Description ...: Initializes the use of WinHTTP functions and returns a WinHTTP-session handle.
; Syntax.........: _WinHttpOpen([$sUserAgent [, $iAccessType [, $sProxyName [, $sProxyBypass [, $iFlags ]]]]])
; Parameters ....: $sUserAgent - String that contains the name of the application or entity calling the WinHTTP functions.
;                  $iAccessType - Type of access required.
;                  $sProxyName - String that contains the name of the proxy server to use when proxy access is specified by setting $iAccessType to $WINHTTP_ACCESS_TYPE_NAMED_PROXY.
;                  $sProxyBypass - String that contains an optional list of host names or IP addresses, or both, that should not be routed through the proxy when $iAccessType is set to $WINHTTP_ACCESS_TYPE_NAMED_PROXY.
;                  $iFlag - Integer that contains the flags that indicate various options affecting the behavior of this function.
; Return values .: Success - Returns valid session handle.
;                          - Sets @error to 0
;                  Failure - Returns 0 and sets @error:
;                  |1 - DllCall failed.
; Author ........: trancexx
; Modified.......:
; Remarks .......: For asynchronous mode set $iFlag to $WINHTTP_FLAG_ASYNC
; Related .......:
; Link ..........; http://msdn.microsoft.com/en-us/library/aa384098(VS.85).aspx
; Example .......; Yes
;
;==========================================================================================
Func _WinHttpOpen($sUserAgent = "AutoIt v3", $iAccessType = $WINHTTP_ACCESS_TYPE_NO_PROXY, $sProxyName = $WINHTTP_NO_PROXY_NAME, $sProxyBypass = $WINHTTP_NO_PROXY_BYPASS, $iFlag = 0)

	Local $a_hCall = DllCall("winhttp.dll", "hwnd", "WinHttpOpen", _
			"wstr", $sUserAgent, _
			"dword", $iAccessType, _
			"wstr", $sProxyName, _
			"wstr", $sProxyBypass, _
			"dword", $iFlag)

	If @error Or Not $a_hCall[0] Then
		Return SetError(1, 0, 0)
	EndIf

	Return SetError(0, 0, $a_hCall[0])

EndFunc   ;==>_WinHttpOpen




; #FUNCTION# ;===============================================================================
;
; Name...........: _WinHttpOpenRequest
; Description ...: Creates an HTTP request handle.
; Syntax.........: _WinHttpOpenRequest($hConnect [, $sVerb [, $sObjectName[, $sVersion [, $sReferrer [, $ppwszAcceptTypes [, $iFlags]]]]]])
; Parameters ....: $hConnect - Handle to an HTTP session returned by _WinHttpConnect().
;                  $sVerb - String that contains the HTTP verb to use in the request. Default is "GET".
;                  $sObjectName - String that contains the name of the target resource of the specified HTTP verb.
;                  $sVersion - String that contains the HTTP version. Default is "HTTP/1.1"
;                  $sReferrer - String that specifies the URL of the document from which the URL in the request $sObjectName was obtained. Default is $WINHTTP_NO_REFERER.
;                  $sAcceptTypes - String that specifies media types accepted by the client. Default is $WINHTTP_DEFAULT_ACCEPT_TYPES
;                  $iFlags - Integer that contains the Internet flag values. Default is $WINHTTP_FLAG_ESCAPE_DISABLE
; Return values .: Success - Returns valid session handle.
;                          - Sets @error to 0
;                  Failure - Returns 0 and sets @error:
;                  |1 - DllCall failed.
; Author ........: trancexx
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........; http://msdn.microsoft.com/en-us/library/aa384099(VS.85).aspx
; Example .......; Yes
;
;==========================================================================================
Func _WinHttpOpenRequest($hConnect, $sVerb = "GET", $sObjectName = "", $sVersion = "HTTP/1.1", $sReferrer = $WINHTTP_NO_REFERER, $sAcceptTypes = $WINHTTP_DEFAULT_ACCEPT_TYPES, $iFlags = $WINHTTP_FLAG_ESCAPE_DISABLE)

	Local $a_hCall = DllCall("winhttp.dll", "hwnd", "WinHttpOpenRequest", _
			"hwnd", $hConnect, _
			"wstr", StringUpper($sVerb), _
			"wstr", $sObjectName, _
			"wstr", StringUpper($sVersion), _
			"wstr", $sReferrer, _
			"wstr*", $sAcceptTypes, _
			"dword", $iFlags)

	If @error Or Not $a_hCall[0] Then
		Return SetError(1, 0, 0)
	EndIf

	Return SetError(0, 0, $a_hCall[0])

EndFunc   ;==>_WinHttpOpenRequest




; #FUNCTION# ;===============================================================================
;
; Name...........: _WinHttpQueryDataAvailable
; Description ...: Returns the availability to be read with WinHttpReadData.
; Syntax.........: _WinHttpQueryDataAvailable($hRequest)
; Parameters ....: $hRequest - handle returned by _WinHttpOpenRequest().
; Return values .: Success - Returns 1 if data is available.
;                          - Returns 0 if no data is available.
;                          - @extended receives the number of available bytes.
;                          - Sets @error to 0
;                  Failure - Returns 0 and sets @error:
;                  |1 - DllCall failed.
; Author ........: trancexx
; Modified.......:
; Remarks .......: _WinHttpReceiveResponse() must have been called for this handle and have completed before _WinHttpQueryDataAvailable is called.
; Related .......:
; Link ..........; http://msdn.microsoft.com/en-us/library/aa384101(VS.85).aspx
; Example .......; Yes
;
;==========================================================================================
Func _WinHttpQueryDataAvailable($hRequest)

	Local $a_iCall = DllCall("winhttp.dll", "int", "WinHttpQueryDataAvailable", _
			"hwnd", $hRequest, _
			"dword*", 0)

	If @error Then
		Return SetError(1, 0, 0)
	EndIf

	Return SetError(0, $a_iCall[2], $a_iCall[0])

EndFunc   ;==>_WinHttpQueryDataAvailable




; #FUNCTION# ;===============================================================================
;
; Name...........: _WinHttpQueryHeaders
; Description ...: Retrieves header information associated with an HTTP request.
; Syntax.........: _WinHttpQueryHeaders($hRequest, $iInfoLevel, $sName)
; Parameters ....: $hRequest - handle returned by _WinHttpOpenRequest().
;                  $iInfoLevel - Specifies a combination of attribute and modifier flags. Default is $WINHTTP_QUERY_RAW_HEADERS_CRLF.
;                  $sName - String that contains the header name. Default is $WINHTTP_HEADER_NAME_BY_INDEX.
; Return values .: Success - Returns string that contains header.
;                          - Sets @error to 0
;                  Failure - Returns 0 and sets @error:
;                  |1 - Initial DllCall failed.
;                  |2 - Main DllCall failed.
; Author ........: trancexx
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........; http://msdn.microsoft.com/en-us/library/aa384102(VS.85).aspx
; Example .......; Yes
;
;==========================================================================================
Func _WinHttpQueryHeaders($hRequest, $iInfoLevel = $WINHTTP_QUERY_RAW_HEADERS_CRLF, $sName = $WINHTTP_HEADER_NAME_BY_INDEX)

	Local $a_iCall = DllCall("winhttp.dll", "int", "WinHttpQueryHeaders", _
			"hwnd", $hRequest, _
			"dword", $iInfoLevel, _
			"wstr", $sName, _
			"ptr", 0, _
			"dword*", 0, _
			"dword*", 0)

	If @error Or $a_iCall[0] Then
		Return SetError(1, 0, 0)
	EndIf

	Local $iSize = $a_iCall[5]

	If Not $iSize Then
		Return SetError(0, 0, "")
	EndIf

	Local $tBuffer = DllStructCreate("wchar[" & $iSize + 1 & "]")

	$a_iCall = DllCall("winhttp.dll", "int", "WinHttpQueryHeaders", _
			"hwnd", $hRequest, _
			"dword", $iInfoLevel, _
			"wstr", $sName, _
			"ptr", DllStructGetPtr($tBuffer), _
			"dword*", $iSize, _
			"dword*", 0)

	If @error Or Not $a_iCall[0] Then
		Return SetError(2, 0, 0)
	EndIf

	Return SetError(0, 0, DllStructGetData($tBuffer, 1))

EndFunc   ;==>_WinHttpQueryHeaders




; #FUNCTION# ;===============================================================================
;
; Name...........: _WinHttpQueryOption
; Description ...: Queries an Internet option on the specified handle.
; Syntax.........: _WinHttpQueryOption($hInternet, $iOption)
; Parameters ....: $hInternet - Handle on which to query information.
;                  $iOption - Integer value that contains the Internet option to query.
; Return values .: Success - Returns data containing requested information.
;                          - Sets @error to 0
;                  Failure - Returns empty string and sets @error:
;                  |1 - Initial DllCall failed.
;                  |2 - Main DllCall failed.
; Author ........: trancexx
; Modified.......:
; Remarks .......: Type of the returned data varies on request.
; Related .......:
; Link ..........; http://msdn.microsoft.com/en-us/library/aa384103(VS.85).aspx
; Example .......; Yes
;
;==========================================================================================
Func _WinHttpQueryOption($hInternet, $iOption)

	Local $a_iCall = DllCall("winhttp.dll", "int", "WinHttpQueryOption", _
			"hwnd", $hInternet, _
			"dword", $iOption, _
			"ptr", 0, _
			"dword*", 0)

	If @error Or $a_iCall[0] Then
		Return SetError(1, 0, "")
	EndIf

	Local $iSize = $a_iCall[4]

	Local $tBuffer

	Switch $iOption
		Case $WINHTTP_OPTION_CONNECTION_INFO, $WINHTTP_OPTION_PASSWORD, $WINHTTP_OPTION_PROXY_PASSWORD, $WINHTTP_OPTION_PROXY_USERNAME, $WINHTTP_OPTION_URL, $WINHTTP_OPTION_USERNAME, $WINHTTP_OPTION_USER_AGENT, _
				$WINHTTP_OPTION_PASSPORT_COBRANDING_TEXT, $WINHTTP_OPTION_PASSPORT_COBRANDING_URL
			$tBuffer = DllStructCreate("wchar[" & $iSize + 1 & "]")
		Case $WINHTTP_OPTION_PARENT_HANDLE, $WINHTTP_OPTION_CALLBACK
			$tBuffer = DllStructCreate("ptr")
		Case $WINHTTP_OPTION_CONNECT_TIMEOUT, $WINHTTP_AUTOLOGON_SECURITY_LEVEL_HIGH, $WINHTTP_AUTOLOGON_SECURITY_LEVEL_LOW, $WINHTTP_AUTOLOGON_SECURITY_LEVEL_MEDIUM, _
				$WINHTTP_OPTION_CONFIGURE_PASSPORT_AUTH, $WINHTTP_OPTION_CONNECT_RETRIES, $WINHTTP_OPTION_EXTENDED_ERROR, $WINHTTP_OPTION_HANDLE_TYPE, $WINHTTP_OPTION_MAX_CONNS_PER_1_0_SERVER, _
				$WINHTTP_OPTION_MAX_CONNS_PER_SERVER, $WINHTTP_OPTION_MAX_HTTP_AUTOMATIC_REDIRECTS, $WINHTTP_OPTION_RECEIVE_RESPONSE_TIMEOUT, $WINHTTP_OPTION_RECEIVE_TIMEOUT, _
				$WINHTTP_OPTION_RESOLVE_TIMEOUT, $WINHTTP_OPTION_SECURITY_FLAGS, $WINHTTP_OPTION_SECURITY_KEY_BITNESS, $WINHTTP_OPTION_SEND_TIMEOUT
			$tBuffer = DllStructCreate("int")
		Case Else
			DllStructCreate("byte[" & $iSize & "]")
	EndSwitch

	$a_iCall = DllCall("winhttp.dll", "int", "WinHttpQueryOption", _
			"hwnd", $hInternet, _
			"dword", $iOption, _
			"ptr", DllStructGetPtr($tBuffer), _
			"dword*", $iSize)

	If @error Or Not $a_iCall[0] Then
		Return SetError(2, 0, "")
	EndIf

	Return SetError(0, 0, DllStructGetData($tBuffer, 1))

EndFunc   ;==>_WinHttpQueryOption




; #FUNCTION# ;===============================================================================
;
; Name...........: _WinHttpReadData
; Description ...: Reads data from a handle opened by the _WinHttpOpenRequest() function.
; Syntax.........: _WinHttpReadData($hRequest [, iMode [, $iNumberOfBytesToRead]])
; Parameters ....: $hRequest - Valid handle returned from a previous call to _WinHttpOpenRequest().
;                  $iMode - Integer representing reading mode. Default is 0 (charset is decoded as it is ANSI).
;                  $iNumberOfBytesToRead - Integer value that contains the number of bytes to read. Default is 8192 bytes.
; Return values .: Success - Returns data read.
;                          - @extended receives the number of bytes read.
;                          - Sets @error to 0
;                  Special: Sets @error to -1 if no more data to read (end reached).
;                  Failure - Returns empty string and sets @error:
;                  |1 - DllCall failed.
; Author ........: trancexx, ProgAndy
; Modified.......:
; Remarks .......: iMode can have these values:
;                  |0 - ANSI
;                  |1 - UTF8
;                  |2 - Binary
; Related .......:
; Link ..........; http://msdn.microsoft.com/en-us/library/aa384104(VS.85).aspx
; Example .......; Yes
;
;==========================================================================================
Func _WinHttpReadData($hRequest, $iMode = 0, $iNumberOfBytesToRead = 8192)

	Local $tBuffer

	Switch $iMode
		Case 1, 2
			$tBuffer = DllStructCreate("byte[" & $iNumberOfBytesToRead & "]")
		Case Else
			$iMode = 0
			$tBuffer = DllStructCreate("char[" & $iNumberOfBytesToRead & "]")
	EndSwitch

	Local $a_iCall = DllCall("winhttp.dll", "int", "WinHttpReadData", _
			"hwnd", $hRequest, _
			"ptr", DllStructGetPtr($tBuffer), _
			"ulong", $iNumberOfBytesToRead, _
			"dword*", 0)

	If @error Or Not $a_iCall[0] Then
		Return SetError(1, 0, "")
	EndIf

	If Not $a_iCall[4] Then
		Return SetError(-1, 0, "")
	EndIf

	Switch $a_iCall[4] < $iNumberOfBytesToRead
		Case True
			Switch $iMode
				Case 0
					Return SetError(0, $a_iCall[4], StringLeft(DllStructGetData($tBuffer, 1), $a_iCall[4]))
				Case 1
					Return SetError(0, $a_iCall[4], BinaryToString(BinaryMid(DllStructGetData($tBuffer, 1), 1, $a_iCall[4]), 4))
				Case 2
					Return SetError(0, $a_iCall[4], BinaryMid(DllStructGetData($tBuffer, 1), 1, $a_iCall[4]))
			EndSwitch
		Case Else
			Switch $iMode
				Case 0, 2
					Return SetError(0, $a_iCall[4], DllStructGetData($tBuffer, 1))
				Case 1
					Return SetError(0, $a_iCall[4], BinaryToString(DllStructGetData($tBuffer, 1), 4))
			EndSwitch
	EndSwitch

EndFunc   ;==>_WinHttpReadData




; #FUNCTION# ;===============================================================================
;
; Name...........: _WinHttpReceiveResponse
; Description ...: Waits to receive the response to an HTTP request initiated by WinHttpSendRequest().
; Syntax.........: _WinHttpReceiveResponse($hRequest)
; Parameters ....: $hRequest - Handle returned by _WinHttpOpenRequest() and sent by _WinHttpSendRequest().
; Return values .: Success - Returns 1.
;                          - Sets @error to 0
;                  Failure - Returns 0 and sets @error:
;                  |1 - DllCall failed.
; Author ........: trancexx
; Modified.......:
; Remarks .......: Must call _WinHttpReceiveResponse() before _WinHttpQueryDataAvailable() and _WinHttpReadData().
; Related .......:
; Link ..........; http://msdn.microsoft.com/en-us/library/aa384105(VS.85).aspx
; Example .......; Yes
;
;==========================================================================================
Func _WinHttpReceiveResponse($hRequest)

	Local $a_iCall = DllCall("winhttp.dll", "int", "WinHttpReceiveResponse", _
			"hwnd", $hRequest, _
			"ptr", 0)

	If @error Or Not $a_iCall[0] Then
		SetError(1, 0, 0)
	EndIf

	Return SetError(0, 0, 1)

EndFunc   ;==>_WinHttpReceiveResponse




; #FUNCTION# ;===============================================================================
;
; Name...........: _WinHttpSendRequest
; Description ...: Sends the specified request to the HTTP server.
; Syntax.........: _WinHttpSendRequest($hRequest [, $sHeaders [, $sOptional [, $iTotalLength [, $iContext]]]])
; Parameters ....: $hRequest - Handle returned by _WinHttpOpenRequest().
;                  $sHeaders - String that contains the additional headers to append to the request. Default is $WINHTTP_NO_ADDITIONAL_HEADERS.
;                  $sOptional - String that contains any optional data to send immediately after the request headers. Default is $WINHTTP_NO_REQUEST_DATA.
;                  $iTotalLength - An unsigned long integer value that contains the length, in bytes, of the total optional data sent. Default is 0.
;                  $iContext - A pointer to a pointer-sized variable that contains an application-defined value that is passed, with the request handle, to any callback functions. Default is 0.
; Return values .: Success - Returns 1.
;                          - Sets @error to 0
;                  Failure - Returns 0 and sets @error:
;                  |1 - DllCall failed.
; Author ........: trancexx
; Modified.......:
; Remarks .......: Specifying optional data ($sOptional) will cause $iTotalLength to receive the size of that data if left default value.
; Related .......:
; Link ..........; http://msdn.microsoft.com/en-us/library/aa384110(VS.85).aspx
; Example .......; Yes
;
;==========================================================================================
Func _WinHttpSendRequest($hRequest, $sHeaders = $WINHTTP_NO_ADDITIONAL_HEADERS, $sOptional = $WINHTTP_NO_REQUEST_DATA, $iTotalLength = 0, $iContext = 0)

	Local $iOptionalLength = StringLen($sOptional)
	Local $structOptional = DllStructCreate("char[" & $iOptionalLength + 1 & "]")
	DllStructSetData($structOptional, 1, $sOptional)

	If Not $iTotalLength Or $iTotalLength < $iOptionalLength Then
		$iTotalLength += $iOptionalLength
	EndIf

	Local $a_iCall = DllCall("winhttp.dll", "int", "WinHttpSendRequest", _
			"hwnd", $hRequest, _
			"wstr", $sHeaders, _
			"dword", 0, _
			"ptr", DllStructGetPtr($structOptional), _
			"dword", $iOptionalLength, _
			"dword", $iTotalLength, _
			"ptr", $iContext)

	If @error Or Not $a_iCall[0] Then
		SetError(1, 0, 0)
	EndIf

	Return SetError(0, 0, 1)

EndFunc   ;==>_WinHttpSendRequest




; #FUNCTION# ;===============================================================================
;
; Name...........: _WinHttpSetCredentials
; Description ...: Passes the required authorization credentials to the server.
; Syntax.........: _WinHttpSetCredentials($hRequest, $iAuthTargets, $iAuthScheme, $sUserName, $sPassword)
; Parameters ....: $hRequest - Valid handle returned by _WinHttpOpenRequest().
;                  $iAuthTargets - Integer that specifies a flag that contains the authentication target.
;                  $iAuthScheme - Integer that specifies a flag that contains the authentication scheme.
;                  $sUserName - String that contains a valid user name.
;                  $sPassword - String that contains a valid password.
; Return values .: Success - Returns 1.
;                          - Sets @error to 0
;                  Failure - Returns 0 and sets @error:
;                  |1 - DllCall failed.
; Author ........: trancexx
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........; http://msdn.microsoft.com/en-us/library/aa384112(VS.85).aspx
; Example .......; Yes
;
;==========================================================================================
Func _WinHttpSetCredentials($hRequest, $iAuthTargets, $iAuthScheme, $sUserName, $sPassword)

	Local $a_iCall = DllCall("winhttp.dll", "int", "WinHttpSetCredentials", _
			"hwnd", $hRequest, _
			"dword", $iAuthTargets, _
			"dword", $iAuthScheme, _
			"wstr", $sUserName, _
			"wstr", $sPassword, _
			"ptr", 0)

	If @error Or Not $a_iCall[0] Then
		Return SetError(1, 0, 0)
	EndIf

	Return SetError(0, 0, 1)

EndFunc   ;==>_WinHttpSetCredentials




; #FUNCTION# ;===============================================================================
;
; Name...........: _WinHttpSetDefaultProxyConfiguration
; Description ...: Sets the default WinHTTP proxy configuration.
; Syntax.........: _WinHttpSetDefaultProxyConfiguration($iAccessType, $Proxy, $ProxyBypass)
; Parameters ....: $iAccessType - Integer value that contains the access type.
;                  $Proxy - String value that contains the proxy server list.
;                  $ProxyBypass - String value that contains the proxy bypass list.
; Return values .: Success - Returns 1.
;                          - Sets @error to 0
;                  Failure - Returns 0 and sets @error:
;                  |1 - DllCall failed.
; Author ........: trancexx
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........; http://msdn.microsoft.com/en-us/library/aa384113(VS.85).aspx
; Example .......; Yes
;
;==========================================================================================
Func _WinHttpSetDefaultProxyConfiguration($iAccessType, $Proxy, $ProxyBypass)

	Local $tProxy = DllStructCreate("wchar[" & StringLen($Proxy) + 1 & "]")
	DllStructSetData($tProxy, 1, $Proxy)

	Local $tProxyBypass = DllStructCreate("wchar[" & StringLen($ProxyBypass) + 1 & "]")
	DllStructSetData($tProxyBypass, 1, $ProxyBypass)

	Local $tWINHTTP_PROXY_INFO = DllStructCreate("dword AccessType;" & _
			"ptr Proxy;" & _
			"ptr ProxyBypass")

	DllStructSetData($tWINHTTP_PROXY_INFO, "AccessType", $iAccessType)
	DllStructSetData($tWINHTTP_PROXY_INFO, "Proxy", DllStructGetPtr($tProxy))
	DllStructSetData($tWINHTTP_PROXY_INFO, "ProxyBypass", DllStructGetPtr($tProxyBypass))

	Local $a_iCall = DllCall("winhttp.dll", "int", "WinHttpSetDefaultProxyConfiguration", "ptr", DllStructGetPtr($tWINHTTP_PROXY_INFO))

	If @error Or Not $a_iCall[0] Then
		Return SetError(1, 0, 0)
	EndIf

	Return SetError(0, 0, 1)

EndFunc   ;==>_WinHttpSetDefaultProxyConfiguration




; #FUNCTION# ;===============================================================================
;
; Name...........: _WinHttpSetOption
; Description ...: Sets an Internet option.
; Syntax.........: _WinHttpSetOption($hInternet, $iOption, $sSetting)
; Parameters ....: $hInternet - Handle on which to set data.
;                  $iOption - Integer value that contains the Internet option to set.
;                  $sSetting - String value that contains desired setting.
; Return values .: Success - Returns 1.
;                          - Sets @error to 0
;                  Failure - Returns 0 and sets @error:
;                  |1 - DllCall failed.
; Author ........: trancexx
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........; http://msdn.microsoft.com/en-us/library/aa384114(VS.85).aspx
; Example .......; Yes
;
;==========================================================================================
Func _WinHttpSetOption($hInternet, $iOption, $sSetting)

	Local $a_iCall = DllCall("winhttp.dll", "int", "WinHttpSetOption", _
			"hwnd", $hInternet, _
			"dword", $iOption, _
			"wstr", $sSetting, _
			"dword", StringLen($sSetting))

	If @error Or Not $a_iCall[0] Then
		Return SetError(1, 0, 0)
	EndIf

	Return SetError(0, 0, 1)

EndFunc   ;==>_WinHttpSetOption




; #FUNCTION# ;===============================================================================
;
; Name...........: _WinHttpSetStatusCallback
; Description ...: Sets up a callback function that WinHTTP can call as progress is made during an operation.
; Syntax.........: _WinHttpSetStatusCallback($hInternet, $pInternetCallback, $iNotificationFlags)
; Parameters ....: $hInternet - Handle for which the callback is to be set.
;                  $fInternetCallback - Callback function to call when progress is made.
;                  $iNotificationFlags - Integer value that specifies flags to indicate which events activate the callback function. Default is $WINHTTP_CALLBACK_FLAG_ALL_NOTIFICATIONS.
; Return values .: Success - Returns a pointer to the previously defined status callback function or NULL if there was no previously defined status callback function.
;                          - Sets @error to 0
;                  Failure - Returns 0 and sets @error:
;                  |1 - DllCall failed.
; Author ........: ProgAndy
; Modified.......: trancexx
; Remarks .......:
; Related .......:
; Link ..........; http://msdn.microsoft.com/en-us/library/aa384115(VS.85).aspx
; Example .......; Yes
;
;==========================================================================================
Func _WinHttpSetStatusCallback($hInternet, $fInternetCallback, $iNotificationFlags = $WINHTTP_CALLBACK_FLAG_ALL_NOTIFICATIONS)

	Local $a_pCall = DllCall("winhttp.dll", "ptr", "WinHttpSetStatusCallback", _
			"hwnd", $hInternet, _
			"ptr", DllCallbackGetPtr($fInternetCallback), _
			"dword", $iNotificationFlags, _
			"ptr", 0)

	If @error Then
		Return SetError(1, 0, 0)
	EndIf

	Return SetError(0, 0, $a_pCall[0])

EndFunc   ;==>_WinHttpSetStatusCallback




; #FUNCTION# ;===============================================================================
;
; Name...........: _WinHttpSetTimeouts
; Description ...: Sets time-outs involved with HTTP transactions.
; Syntax.........: _WinHttpSetTimeouts($hInternet, $iResolveTimeout, $iConnectTimeout, $iSendTimeout, $iReceiveTimeout)
; Parameters ....: $hInternet - Handle returned by _WinHttpOpen() or _WinHttpOpenRequest().
;                  $iResolveTimeout - Integer that specifies the time-out value, in milliseconds, to use for name resolution.
;                  $iConnectTimeout - Integer that specifies the time-out value, in milliseconds, to use for server connection requests.
;                  $iSendTimeout - Integer that specifies the time-out value, in milliseconds, to use for sending requests.
;                  $iReceiveTimeout - integer that specifies the time-out value, in milliseconds, to receive a response to a request.
; Return values .: Success - Returns 1.
;                          - Sets @error to 0
;                  Failure - Returns 0 and sets @error:
;                  |1 - DllCall failed.
; Author ........: trancexx
; Modified.......:
; Remarks .......: Initial values are: - $iResolveTimeout = 0
;                                      - $iConnectTimeout = 60000
;                                      - $iSendTimeout = 30000
;                                      - $iReceiveTimeout = 30000
; Related .......:
; Link ..........; http://msdn.microsoft.com/en-us/library/aa384116(VS.85).aspx
; Example .......; Yes
;
;==========================================================================================
Func _WinHttpSetTimeouts($hInternet, $iResolveTimeout, $iConnectTimeout, $iSendTimeout, $iReceiveTimeout)

	Local $a_iCall = DllCall("winhttp.dll", "int", "WinHttpSetTimeouts", _
			"hwnd", $hInternet, _
			"int", $iResolveTimeout, _
			"int", $iConnectTimeout, _
			"int", $iSendTimeout, _
			"int", $iReceiveTimeout)

	If @error Or Not $a_iCall[0] Then
		Return SetError(1, 0, 0)
	EndIf

	Return SetError(0, 0, 1)

EndFunc   ;==>_WinHttpSetTimeouts




; #FUNCTION# ;===============================================================================
;
; Name...........: _WinHttpTimeFromSystemTime
; Description ...: Formats a system date and time according to the HTTP version 1.0 specification.
; Syntax.........: _WinHttpTimeFromSystemTime()
; Parameters ....: None.
; Return values .: Success - Returns 1.
;                          - Sets @error to 0
;                  Failure - Returns 0 and sets @error:
;                  |1 - Initial DllCall failed.
;                  |2 - Main DllCall failed.
; Author ........: trancexx
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........; http://msdn.microsoft.com/en-us/library/aa384117(VS.85).aspx
; Example .......; Yes
;
;==========================================================================================
Func _WinHttpTimeFromSystemTime()

	Local $SYSTEMTIME = DllStructCreate("ushort Year;" & _
			"ushort Month;" & _
			"ushort DayOfWeek;" & _
			"ushort Day;" & _
			"ushort Hour;" & _
			"ushort Minute;" & _
			"ushort Second;" & _
			"ushort Milliseconds")

	DllCall("kernel32.dll", "none", "GetSystemTime", "ptr", DllStructGetPtr($SYSTEMTIME))

	If @error Then
		Return SetError(1, 0, 0)
	EndIf

	Local $sTime = DllStructCreate("wchar[62]")

	Local $a_iCall = DllCall("winhttp.dll", "int", "WinHttpTimeFromSystemTime", _
			"ptr", DllStructGetPtr($SYSTEMTIME), _
			"ptr", DllStructGetPtr($sTime))

	If @error Or Not $a_iCall[0] Then
		Return SetError(2, 0, 0)
	EndIf

	Return SetError(0, 0, DllStructGetData($sTime, 1))

EndFunc   ;==>_WinHttpTimeFromSystemTime




; #FUNCTION# ;===============================================================================
;
; Name...........: _WinHttpTimeToSystemTime
; Description ...: Takes an HTTP time/date string and converts it to array (SYSTEMTIME structure values).
; Syntax.........: _WinHttpTimeToSystemTime($sHttpTime)
; Parameters ....: $sHttpTime - Date/time string to convert.
; Return values .: Success - Returns array which first element [0] is Year,
;                                        second element [1] is Month,
;                                        third element [2] is DayOfWeek,
;                                        fourth element [3] is Day,
;                                        fifth element [4] is Hour,
;                                        sixth element [5] is Minute,
;                                        seventh element [6] is Second.,
;                                        eighth element [7] is Milliseconds.
;                          - Sets @error to 0
;                  Failure - Returns 0 and sets @error:
;                  |1 - DllCall failed.
; Author ........: trancexx
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........; http://msdn.microsoft.com/en-us/library/aa384118(VS.85).aspx
; Example .......; Yes
;
;==========================================================================================
Func _WinHttpTimeToSystemTime($sHttpTime)

	Local $SYSTEMTIME = DllStructCreate("ushort Year;" & _
			"ushort Month;" & _
			"ushort DayOfWeek;" & _
			"ushort Day;" & _
			"ushort Hour;" & _
			"ushort Minute;" & _
			"ushort Second;" & _
			"ushort Milliseconds")

	Local $sTime = DllStructCreate("wchar[62]")
	DllStructSetData($sTime, 1, $sHttpTime)

	Local $a_iCall = DllCall("winhttp.dll", "int", "WinHttpTimeToSystemTime", _
			"ptr", DllStructGetPtr($sTime), _
			"ptr", DllStructGetPtr($SYSTEMTIME))

	If @error Or Not $a_iCall[0] Then
		Return SetError(2, 0, 0)
	EndIf

	Local $a_Ret[8] = [DllStructGetData($SYSTEMTIME, "Year"), _
			DllStructGetData($SYSTEMTIME, "Month"), _
			DllStructGetData($SYSTEMTIME, "DayOfWeek"), _
			DllStructGetData($SYSTEMTIME, "Day"), _
			DllStructGetData($SYSTEMTIME, "Hour"), _
			DllStructGetData($SYSTEMTIME, "Minute"), _
			DllStructGetData($SYSTEMTIME, "Second"), _
			DllStructGetData($SYSTEMTIME, "Milliseconds")]

	Return SetError(0, 0, $a_Ret)

EndFunc   ;==>_WinHttpTimeToSystemTime




; #FUNCTION# ;===============================================================================
;
; Name...........: _WinHttpWriteData
; Description ...: Writes request data to an HTTP server.
; Syntax.........: _WinHttpWriteData($hRequest, $data [, $iMode])
; Parameters ....: $hRequest - Valid handle returned by _WinHttpSendRequest().
;                  $data - Data to write.
;                  $iMode - Integer representing writing mode. Default is 0 - write ANSI string.
; Return values .: Success - Returns 1
;                          - @extended receives the number of bytes written.
;                          - Sets @error to 0
;                  Failure - Returns 0 and sets @error:
;                  |1 - DllCall failed.
; Author ........: trancexx, ProgAndy
; Modified.......:
; Remarks .......: $data variable is either string or binary data to write.
;                  $iMode can have these values:
;                  |0 - to write ANSI string
;                  |1 - to write binary data
; Related .......:
; Link ..........; http://msdn.microsoft.com/en-us/library/aa384120(VS.85).aspx
; Example .......; Yes
;
;==========================================================================================
Func _WinHttpWriteData($hRequest, $data, $iMode = 0)

	Local $iNumberOfBytesToWrite, $tData
	Switch $iMode
		Case 1
			$iNumberOfBytesToWrite = BinaryLen($data)
			$tData = DllStructCreate("byte[" & $iNumberOfBytesToWrite & "]")
		Case Else
			$iNumberOfBytesToWrite = StringLen($data)
            $tData = DllStructCreate("char[" & $iNumberOfBytesToWrite + 1 & "]")
	EndSwitch

	DllStructSetData($tData, 1, $data)

	Local $a_iCall = DllCall("winhttp.dll", "int", "WinHttpWriteData", _
			"hwnd", $hRequest, _
			"ptr", DllStructGetPtr($tData), _
			"dword", $iNumberOfBytesToWrite, _
			"dword*", 0)

	If @error Or Not $a_iCall[0] Then
		Return SetError(1, 0, 0)
	EndIf

	Return SetError(0, $a_iCall[4], 1)


EndFunc   ;==>_WinHttpWriteData
