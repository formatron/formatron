# <%= @name %>

The <%= @name %> stack.

## Dependencies

- Ruby
- Bundler

    ```
    gem install bundler
    ```

- Other gem dependencies

    ```
    bundle install
    ```

## Requirements and Configuration

Top level configuration is in `Formatronfile`

The configuration is set per environment and stored encrypted with the appropriate KMS key in the s3 bucket.

- `./config/common/` - contains the shared configuration
- `./config/production/` - contains the production configuration
- `./config/test/` - contains the test configuration

To deploy the stack, create a `credentials.json` file in the root of this project with the following details from your administrator account

```javascript
{
  "accessKeyId": "YOUR_ACCESS_KEY_ID",
  "secretAccessKey": "YOUR_SECRET_ACCESS_KEY"
}
```

then call

```
bundle exec formatron deploy test
```

or

```
bundle exec formatron deploy production
```
