require "rails_helper"

# When signed in:
# should be able to view my own items

# -- new items
# should be able to view form to make a new item
# should be able to create an item, given some form data

# -- edit items
# should be able to view form to edit an item that belongs to me
# should NOT be able to view form to edit an item that does not belong to me
# should be able to edit an item, given some form data, that belongs to me
# should NOTE be able to edit an item, given some form data, that does not belong to me

# -- delete item
# should be able to delete an item that belongs to me
# should not be able to delete an item that does not belong to me

# When not signed in:
# should not be able to view to do list items
# should not be able to view form to make an item
# should not be able to create an item, given valid form data
# should not be able to view form to edit an item
# should not be able to edit an item, given valid form data
# should not be able to delete an item

RSpec.describe "Items", type: :request do

    context "When signed in" do
        before do
            @user1 = User.create(email: "proper@proper.com", password: "proper123")
            @user1_item = Item.create(text: "wash dishes", user_id: user1.id)
            sign_in @user1
        end

        it "should allow me to view my own items" do
            get root_path
            expect(response).to have_http_status(:ok)
        end

        describe "make an item" do
            it "should let me view the new item form" do
                get new_item_path
                expect(response).to have_http_status(:ok)
            end

            it "should be able to create a valid item" do
                expect {
                        post items_path, params: { item: {text: "clean out the fridge"}}
                }.to change(Post, count)

                expect(response).to root_path
            end
        end

        it "should not get /items/:id/edit for someone elses item" do
            get edit_items_path(@user1_item)
            expect(response).to redirect_to(root_path)
        end

        it "should not patch /item/:id for someone elses item" do
            patch items_path(@user1_item), params: { item: { text: "wash car"}}
            user1_item_reloaded = Item.find(@user1_item.id)

            expect(user1_item_reloaded.text).to eq("wash dishes")
            expect(response).to redirect_to(root_path)
        end

        it "should not delete /items/:id" do
            hacker_user = User.create(email: "hacker@hacker.com", password: "hacker123")


            sign_in hacker_user
            expect {
                delete items_path(@user1_item)
            }.not_to change(Item, count)

            expect(response).to redirect_to(root_path)

        end
    end

    context "When not signed in" do

        it "should not get /items" do
            #GET /items
            get items_path
            #expect to be redirected to sign in page
            expect(response).to redirect_to(new_user_session_path)
        end

        it "should not get /items/new" do
            get new_items_path
            expect(response).to redirect_to(new_user_session_path)
        end

        it "should not post /items" do
            expect {
                post items_path, params: { item: { text: "walk the dog" } }
            }.not_to change(Post, count)

            expect(response).to redirect_to(new_user_session_path)
        end

        it "should not get /edit" do
            get edit_items_path
            expect(response).to redirect_to(new_user_session_path)
        end

        it "should not let me update item" do
            user = User.create(email: "bob@bob.com", password: "bob")
            item = Item.create(text: "walk the dog", user_id: user.id)

            patch item_path(item), params: { item: { text: "take out the trash" }}
            item2 = Item.find(item.id)

            expect(item2.text).not_to eq("take out the trash")
            
            expect(response).to redirect_to(new_user_session_path)
        end

        it "should not delete an item" do
            user = User.create(email: "mary@mary.com", password: "mary")
            item = Item.create(text: "delete me", user_id: user.id)

            expect {
                delete item_path(item)
            }.not_to change(Post,count)

            expect(response).to redirect_to(new_user_session_path)
        end

    end

end