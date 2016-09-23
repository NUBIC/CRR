class MergeUserRecords < ActiveRecord::Migration
  def up
    User.select(:netid).group(:netid).having('count(*) > 1').each do |user|
      puts "Duplicate record found: #{user.netid}"
      users = User.where(netid: user.netid).order(sign_in_count: :desc).to_a
      user_to_keep    = users.shift

      users.each do |user_to_destroy|
        user_to_destroy.studies.each do |study|
          user_to_keep.studies << study
        end
        user_to_destroy.studies = []

        user_to_destroy.comments.each do |comment|
          comment.user = user_to_keep
          comment.save!
        end

        user_to_destroy.searches.each do |search|
          search.user = user_to_keep
          search.save!
        end

        user_to_destroy.destroy
      end
    end
  end

  def down
  end
end
