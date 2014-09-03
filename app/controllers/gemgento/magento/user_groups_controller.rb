module Gemgento
  class Magento::UserGroupsController < MagentoController

    def update
      @user_group = Gemgento::UserGroup.find_or_initialize_by(magento_id: params[:id])
      @user_group.code = params[:data][:code]
      @user_group.save

      render nothing: true
    end

    def destroy
      if @user_group = Gemgento::UserGroup.find_by(magento_id: params[:id])
        @user_group.destroy
      end

      render nothing: true
    end

  end
end