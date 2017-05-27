#!/usr/bin/ruby2.2
# require_relative 'setup'
# require_relative 'logger'

def update_place(member)
  place = GeodirPlace.find_by(:geodir_member_id => member.member_id, :geodir_branch_id => member.branch_id)
  # if place or not member.destroyed?
  #   puts "Member:#{member.id}:#{member.member_id}:#{member.branch_id}:#{member.grade}"
  # end
  post =  if place
            # puts " * Place exists"
            place.place_post
          elsif not member.destroyed?
            # puts " * Place new"
            PlacePost.new
          else
            nil
          end
  if post 
    if member.destroyed?
      $stderr.puts "    destroyed Post:#{post.id}, Member:#{member.id}:#{member.member_id}:#{member.branch_id}:#{member.grade}"
      post.destroy
      member.update_attribute(:post_id, nil);
    else
      post.update_attributes_from_member(member)
      if post.changed? or post.geodir_place.changed?
        if not post.save
          puts "NOT SAVED: Post:#{post.id}:#{post.persisted? ? 'Existing' : 'New'} Member:#{member.id}:#{member.member_id}:#{member.branch_id}:#{member.grade}:#{member.company_name}"
          puts "      PostErrors: #{post.errors.messages.inspect}"
        else
          # post.geodir_place.save
        #   puts " * updated Post:#{post.id}"
          puts "    updated: Post:#{post.id}:#{post.persisted? ? 'Existing' : 'New'} Member:#{member.id}:#{member.member_id}:#{member.branch_id}:#{member.grade}:#{member.company_name}"
          member.update_attribute(:post_id, post.ID);
        end
      # else
      #   puts " * not changed Post:#{post.id}, Member:#{member.id}:#{member.member_id}:#{member.branch_id}"
      end
    end
    # $stderr.puts "   * #{post.ID}"
  end
end

funeral_home_members = Member.unscoped.where("grade < 30")
$stderr.puts " ** (#{Member.where('grade < 30').count}) geodir from uk homes"
funeral_home_members.each do |member|
  update_place(member)
end

offshore_funeral_homes = Member.unscoped.where(:grade => 50)
$stderr.puts " ** (#{Member.where(:grade => 50).count}) geodir from abroad homes"
offshore_funeral_homes.each do |member|
  update_place(member)
end
