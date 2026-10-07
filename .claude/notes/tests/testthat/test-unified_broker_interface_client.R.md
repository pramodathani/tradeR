# tests/testthat/test-unified_broker_interface_client.R

The mock passed to `httr2::local_mocked_responses()` takes its argument as `req`, not `request`, because httr2 checks the argument's name and refuses any other. It is the one abbreviated name in the tests, forced by the library's interface.

`UnifiedBrokerInterfaceTestServer` plays UBI: it records each request and answers with the next reply in its queue, so a test states the exact sequence, such as a connect, a 401, a reconnect and the retried request.
