Logging account
==================

Separate empty account solely used for storing and managing cloudtrail logging.

Use the cloudtrail resource found in `logging.tf` in other accounts and add the account number to `logging.tfvars` to enable access.

Make sure you always update your logging account first prior to other accounts if you change it.

You can use `state.tf` to reference your logging account and use its outputs to sync changes more cleanly.
