p ENV['MAMIYA_AWS_ACCESS_KEY_ID']

set :storage, {
      type: :s3,
      bucket: ENV['MAMIYA_S3_BUCKET'],
      region: 'ap-northeast-1',
      access_key_id: ENV['MAMIYA_AWS_ACCESS_KEY_ID'],
      secret_access_key: ENV['MAMIYA_AWS_SECRET_ACCESS_KEY']
    }
