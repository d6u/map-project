class Api::FriendshipsController < Api::ApiBaseController

  # GET    /api/friendships      #index
  # POST   /api/friendships      #create
  # GET    /api/friendships/:id  #show
  # PATCH  /api/friendships/:id  #update
  # PUT    /api/friendships/:id  #update
  # DELETE /api/friendships/:id  #destroy


  before_action :find_friendship, except: [:index, :create]


  # GET    /api/friendships
  def index
    render :json => @user.friendships.order('status DESC'), :include => :friend
  end


  # POST   /api/friendships
  def create
    @friendship = @user.friendships.find_by_friend_id(params[:friendship][:friend_id])

    # --- friendship record already exist ---
    if @friendship
      # user blocked friend
      if @friendship.status < 0
        render :json => {:error      => true,
                         :message    => 'You have blocked this user.',
                         :error_code => 'FS000'},
               :status => 409
      # request already sent
      elsif @friendship.status == 0
        render :json => {:error      => true,
                         :message    => 'Friend request has already sent.',
                         :error_code => 'FS001'},
               :status => 409
      # already friends
      else
        render :json => {:error      => true,
                         :message    => 'You are already friends',
                         :error_code => 'FS002'},
               :status => 409
      end

    # --- brand new friendship ---
    else
      @friendship = Friendship.new params.require(:friendship).permit(:friend_id, :comments)
      @user.friendships << @friendship
      render json: @friendship

      # Create notice object and send to Node.js server
      notice = Notice.create_add_friend_request(@user, @friendship.friend_id, @friendship, @friendship.comments)
      send_push_notice(notice)
    end
  end


  # GET    /api/friendships/:id
  def show
    render json: @friendship
  end


  # PATCH  /api/friendships/:id
  # PUT    /api/friendships/:id
  def update
    @friendship.attributes = params.require(:friendship).permit(:comments)
    @friendship.save if @friendship.changed?
    render json: @friendship
  end


  # DELETE /api/friendships/:id
  def destroy
    @friendship.destroy()
    render json: @friendship
  end


  # --- Private ---

  def find_friendship
    @friendship = Friendship.joins(:friend).
                  select('friendships.*, users.name, users.profile_picture').
                  find(params[:id])
  end

  private :find_friendship

end
