Sequel.migration do
  down do
    drop_table :tokens, :tweets
  end

  up do
    unless table_exists?(:tokens)
      create_table :tokens do
        varchar :token, :null => false, :size => 255
        varchar :type,  :null => false, :size => 255
        bigint  :count, :null => false, :default => 0

        primary_key [:type, :token]
        index :token
      end
    end

    unless table_exists?(:tweets)
      create_table :tweets do
        bigint :id, :null => false, :primary_key => true

        text     :tweet,      :null => false, :size => 8192
        datetime :created_at, :null => false
        varchar  :type,       :null => true,  :size => 255
        integer  :votes,      :null => false, :default => 0
      end
    end
  end
end
