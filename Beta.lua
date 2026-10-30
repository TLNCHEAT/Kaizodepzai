-- ==============================================================================
--  TLN CHEAT - MERGED EDITION (VI + EN + ID | 3-LANG PILL | FULL FEATURES)
-- ==============================================================================

local NEW_TITLE       = "TLN CHEAT"
local TELEGRAM_LINK   = "https://t.me/addlist/dlX9dRlQmyNlMWFl"
local CHILLI_LOGO_ID  = "rbxassetid://100224396235670"
local LOGO_BG_COLOR   = Color3.fromRGB(5, 7, 15)
local ISLAND_BLACK_BG = Color3.fromRGB(0, 0, 0)

-- ==================== 1. LOAD VENYXHUB ====================
if not getgenv().__TLNV5NewLoaded then
    getgenv().__TLNV5NewLoaded = true
    getgenv().__TLNHubReady    = false
    getgenv().__TLNHub         = nil
    task.spawn(function()
        local ok, result = pcall(function()
            return loadstring(game:HttpGet(
                "https://raw.githubusercontent.com/tienkhanh1/Venyx/main/VenyxHub"
            ))()
        end)
        if ok then
            getgenv().__TLNHub      = result   -- hub object (nếu hub trả về)
            getgenv().__TLNHubReady = true
        else
            warn("[TLN] VenyxHub load failed:", result)
            getgenv().__TLNHubReady = true     -- vẫn set true để không treo loop
        end
    end)
end

-- Helper: chờ hub sẵn sàng rồi chạy callback
local function onHubReady(callback)
    task.spawn(function()
        local t = 0
        while not getgenv().__TLNHubReady and t < 30 do
            task.wait(0.3); t = t + 0.3
        end
        callback(getgenv().__TLNHub)
    end)
end

local Players     = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
local TweenService = game:GetService("TweenService")
local CoreGui     = game:GetService("CoreGui")

local roots = {
    gethui and gethui(),
    CoreGui,
    LocalPlayer:WaitForChild("PlayerGui")
}

local ActiveGradients = {}

local COLOR_SEQ_RAINBOW = ColorSequence.new({
    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255,  55,  55)),
    ColorSequenceKeypoint.new(0.20, Color3.fromRGB(255, 175,  40)),
    ColorSequenceKeypoint.new(0.40, Color3.fromRGB(255, 235,  50)),
    ColorSequenceKeypoint.new(0.60, Color3.fromRGB( 50, 255, 130)),
    ColorSequenceKeypoint.new(0.80, Color3.fromRGB( 60, 185, 255)),
    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255,  55,  55)),
})

if not getgenv().__ChilliV5RainbowLoop then
    getgenv().__ChilliV5RainbowLoop = true
    task.spawn(function()
        local rot = 0
        while true do
            rot = (rot + 4) % 360
            for i = #ActiveGradients, 1, -1 do
                local g = ActiveGradients[i]
                if g and g.Parent then g.Rotation = rot
                else table.remove(ActiveGradients, i) end
            end
            task.wait(0.05)  -- giảm từ 0.03 → bớt giật
        end
    end)
end

-- ==================== 2. FPS ẢO (85–120) ====================
local currentFakeFps = math.random(96, 112)
local function generateNextFakeFps()
    local delta = math.random(-4, 4)
    currentFakeFps = math.clamp(currentFakeFps + delta, 85, 120)
    return currentFakeFps
end
local function isFpsCounterText(str)
    if not str then return false end
    return str:find("FPS") ~= nil and str:find("ms") ~= nil
end
local function hookFakeFpsCounter(lbl)
    if not (lbl:IsA("TextLabel") or lbl:IsA("TextButton")) then return end
    local function applyFakeFps()
        if lbl:GetAttribute("__UpdatingFps") then return end
        local raw = lbl.Text
        if not isFpsCounterText(raw) then return end
        lbl:SetAttribute("__UpdatingFps", true)
        local fakeVal = generateNextFakeFps()
        local patched = raw:gsub("%d+%s*FPS", tostring(fakeVal) .. " FPS", 1)
        if lbl.Text ~= patched then lbl.Text = patched end
        task.defer(function() lbl:SetAttribute("__UpdatingFps", false) end)
    end
    applyFakeFps()
    if not lbl:GetAttribute("__FpsHooked") then
        lbl:SetAttribute("__FpsHooked", true)
        lbl:GetPropertyChangedSignal("Text"):Connect(function()
            if not lbl:GetAttribute("__UpdatingFps") and isFpsCounterText(lbl.Text) then
                applyFakeFps()
            end
        end)
        task.spawn(function()
            while lbl and lbl.Parent do
                task.wait(0.7)
                if isFpsCounterText(lbl.Text) then applyFakeFps() end
            end
        end)
    end
end

-- ==================== 3. DỊCH THUẬT ====================
local currentLanguage = "VI"
local FastCache       = {}
local TrackedTexts    = {}
local GlobalRefreshIslandStatus = nil

-- ---- EXACT VI ----
local EXACT_MATCH_VI = {
    ["Idle"]="Đang rảnh",["Waiting"]="Đang chờ",["Nothing"]="Không có gì",
    ["Waiting in safe zone"]="Đợi ở vùng an toàn",["Returning to safe zone"]="Đang về vùng an toàn",
    ["Returning home"]="Đang quay về nhà",["Going home"]="Đang về nhà",
    ["Delivering egg"]="Đang giao trứng về chuồng",["Dropping egg"]="Đang thả trứng",
    ["Dropping eggs"]="Đang thả trứng",["Selling eggs"]="Đang bán trứng",
    ["Selling pets"]="Đang bán pet",["Selling lab eggs"]="Đang bán trứng Lab",
    ["Hatching eggs"]="Đang ấp trứng",["Placing eggs"]="Đang đặt trứng",
    ["Mutating eggs"]="Đang đột biến trứng",["Fusing pets"]="Đang dung hợp pet",
    ["Hopping server"]="Đang đổi máy chủ",["Rejoining"]="Đang vào lại phòng",
    ["Avoiding guard"]="Đang né vệ sĩ",["Evading guard"]="Đang né vệ sĩ",
    ["Using treadmill"]="Đang chạy máy tập",["Upgrading treadmill"]="Đang nâng cấp máy tập",
    ["Upgrading base"]="Đang nâng cấp căn cứ",["Claiming rewards"]="Đang nhận thưởng",
    ["Claiming offline cash"]="Đang nhận tiền ngoại tuyến",["Catching shooting star"]="Đang bắt sao băng",
    ["Catching butterfly"]="Đang bắt bướm",["Joining race"]="Đang vào đường đua",
    ["Racing"]="Đang đua xe",["Home"]="Trang Chủ",["Dashboard"]="Bảng Điều Khiển",
    ["Welcome back"]="Chào mừng trở lại",["TLN CHEAT Discord"]="TLN CHEAT Discord",
    ["Updates, keys, support"]="Cập nhật, nhận key, hỗ trợ",["Copy Invite"]="Chép Link Mời",
    ["Discord"]="Discord",["MONEY /S"]="TIỀN /GIÂY",["OPEN"]="MỞ",
    ["Welcome to TLN CHEAT 1.0.0! Join our Discord for updates and support"]="Chào mừng tới TLN CHEAT! Tham gia Discord để cập nhật và nhận hỗ trợ",
    ["Beta version"]="Phiên bản Beta",
    ["This is a test build. Features may change and bugs can happen."]="Đây là bản thử nghiệm. Tính năng có thể thay đổi và phát sinh lỗi.",
    ["Rejoin"]="Vào lại",["Server hop"]="Đổi server",["Copy Job ID"]="Chép Job ID",
    ["Unload hub"]="Tắt Hub",["Save config"]="Lưu cấu hình",["Hide UI"]="Ẩn Menu",
    ["SESSION"]="PHIÊN CHƠI",["STOLEN"]="ĐÃ CƯỚP",["LAST EGG"]="TRỨNG CUỐI",
    ["PLACED"]="ĐÃ ĐẶT",["HATCHED"]="ĐÃ ẤP",["NIGHT IN"]="ĐÊM SAU",
    ["SESSION TIME"]="THỜI GIAN",["BEST STEAL"]="CƯỚP TỐT NHẤT",
    ["EGG BAG"]="TÚI TRỨNG",["PET BAG"]="TÚI PET",["WHAT'S NEW"]="CÓ GÌ MỚI",
    ["NEW"]="MỚI",["Event"]="Sự Kiện",["Search"]="Tìm kiếm",["Filter"]="Lọc tìm",
    ["Steal"]="Cướp Trứng",["Auto Steal"]="Tự Động Cướp",["AUTO STEAL"]="TỰ ĐỘNG CƯỚP",
    ["Auto steal"]="Tự động cướp",["Egg Predictor"]="Dự Đoán Trứng",
    ["EGG PREDICTOR"]="DỰ ĐOÁN TRỨNG",["Go to egg"]="Di chuyển tới trứng",
    ["Teleport to egg"]="Dịch chuyển tới trứng",["Tween"]="Bay (Tween)",
    ["Delivery method"]="Cách mang về",["Fast tween speed"]="Tốc độ bay nhanh",
    ["Tween speed"]="Tốc độ bay",["Steal missing index eggs"]="Cướp trứng thiếu trong Chỉ mục",
    ["Steal back from players"]="Cướp lại từ người chơi",["Anti guard"]="Chống vệ sĩ",
    ["Drop eggs at safe zone"]="Thả trứng ở vùng an toàn",["FILTER"]="BỘ LỌC",
    ["Zones"]="Khu vực",["None"]="Không có",["Steal first"]="Ưu tiên cướp",
    ["Best value"]="Giá trị cao nhất",["Lowest value"]="Giá trị thấp nhất",
    ["Best rarity"]="Độ hiếm cao nhất",["Best mutation"]="Đột biến tốt nhất",
    ["Biggest"]="Kích thước to nhất",["Closest"]="Khoảng cách gần nhất",
    ["Mutations"]="Đột biến",["Rarities"]="Độ hiếm",["Only these eggs"]="Chỉ những trứng này",
    ["Min value /s"]="Giá trị tối thiểu /s",["Off"]="Tắt",
    ["Sell cheapest egg when bag is full"]="Bán trứng rẻ nhất khi đầy túi",
    ["Keep lab eggs"]="Giữ lại trứng Lab",["AUTO HOP SERVER"]="TỰ ĐỔI MÁY CHỦ",
    ["Only sell eggs below /s"]="Chỉ bán trứng dưới mức /s",["EGG SHOWCASE"]="TRƯNG BÀY TRỨNG",
    ["Sort eggs"]="Sắp xếp trứng",["Preview card"]="Thẻ xem trước",
    ["Pick one"]="Chọn một mục",["Pick any"]="Chọn bất kỳ",["Value"]="Giá trị",
    ["Rarity"]="Độ hiếm",["Time left"]="Thời gian còn lại",["Default"]="Mặc định",
    ["Clear"]="Xóa chọn",["Select all"]="Chọn tất cả",["SIZE"]="KÍCH CỠ",
    ["WEIGHT"]="CÂN NẶNG",["READY"]="SẴN SÀNG",["IN BAG"]="TRONG TÚI",
    ["GROWING"]="ĐANG LỚN",["Hatch now"]="Ấp ngay",["Hold egg"]="Cầm trứng",
    ["Fly to egg"]="Bay tới trứng",
    ["Enchanted Forest"]="Rừng Phù Phép (Enchanted Forest)",["Light Dark"]="Sáng Tối (Light Dark)",
    ["Titan Temple"]="Đền Titan (Titan Temple)",["Cherry Blossom"]="Hoa Anh Đào (Cherry Blossom)",
    ["Prehistoric"]="Tiền Sử (Prehistoric)",["Abyss Ocean"]="Đáy Đại Dương (Abyss Ocean)",
    ["Volcano"]="Núi Lửa (Volcano)",["Snow"]="Tuyết (Snow)",["Jungle"]="Rừng Rậm (Jungle)",
    ["Desert"]="Sa Mạc (Desert)",["Lake"]="Hồ Nước (Lake)",["Forest"]="Khu Rừng (Forest)",
    ["Silver"]="Bạc (Silver)",["Rainbow"]="Cầu Vồng (Rainbow)",["Golden"]="Vàng (Golden)",
    ["Fractured"]="Rạn Nứt (Fractured)",["Scrambled"]="Hỗn Loạn (Scrambled)",
    ["Enchanted"]="Phù Phép (Enchanted)",["Nitro"]="Nitro",
    ["SCRAMBLED"]="HỖN LOẠN",["NITRO"]="NITRO",["FRACTURED"]="RẠN NỨT",["ENCHANTED"]="PHÙ PHÉP",
    ["Farm"]="Cày Cuốc",["Pen"]="Chuồng Ấp",["PEN"]="CHUỒNG ẤP",
    ["Treadmill"]="Máy Tập",["TREADMILL"]="MÁY TẬP CHẠY",["Mutate"]="Đột Biến",
    ["MUTATE"]="ĐỘT BIẾN",["Sell"]="Bán",["SELL"]="BÁN TỰ ĐỘNG",
    ["Fuse"]="Dung Hợp",["FUSE"]="DUNG HỢP",["Priority"]="Ưu Tiên",
    ["PRIORITY"]="THỨ TỰ ƯU TIÊN",["AUTO PLACE"]="TỰ ĐỘNG ĐẶT TRỨNG",
    ["Auto place"]="Tự động đặt trứng",["Place when"]="Đặt khi",["Always"]="Luôn luôn",
    ["Place first"]="Ưu tiên đặt",["AUTO HATCH"]="TỰ ĐỘNG ẤP TRỨNG",
    ["Auto hatch"]="Tự động ấp trứng",["Equip best pets"]="Trang bị pet mạnh nhất",
    ["READY NOW"]="SẴN SÀNG ẤP",["Auto treadmill"]="Tự chạy máy tập",
    ["Auto upgrade treadmill"]="Tự nâng cấp máy tập",["PROGRESS"]="TIẾN TRÌNH",
    ["Auto upgrade base"]="Tự nâng cấp căn cứ",["Auto buy trails"]="Tự mua vệt sáng",
    ["Auto claim offline cash"]="Tự nhận tiền ngoại tuyến",
    ["Auto claim index rewards"]="Tự nhận thưởng Chỉ mục",["AUTO MUTATE"]="TỰ ĐỘNG ĐỘT BIẾN",
    ["Auto mutate"]="Tự động đột biến",["MUTATE FILTER"]="BỘ LỌC ĐỘT BIẾN",
    ["Use items"]="Dùng vật phẩm",["Mutate first"]="Ưu tiên đột biến",
    ["Auto buy Nitro"]="Tự mua Nitro",["PETS"]="THÚ CƯNG (PETS)",["EGGS"]="TRỨNG (EGGS)",
    ["Auto sell pets"]="Tự động bán pet",["Auto sell eggs"]="Tự động bán trứng",
    ["Sell rarities"]="Độ hiếm bán",["Never sell"]="Không bao giờ bán",
    ["Only mutations"]="Chỉ bán đột biến",["Only below /s"]="Chỉ dưới mức /s",
    ["Keep mutated"]="Giữ lại đồ đột biến",["Sell matching pets now"]="Bán các pet khớp ngay",
    ["Sell matching eggs now"]="Bán các trứng khớp ngay",["LAB EGGS"]="TRỨNG PHÒNG LAB",
    ["FAVORITE"]="YÊU THÍCH (KHÓA)",["Auto favorite"]="Tự động khóa bảo vệ",
    ["Auto sell lab eggs"]="Tự động bán trứng Lab",
    ["Sell matching lab eggs now"]="Bán trứng Lab khớp ngay",["Match"]="Điều kiện khớp",
    ["All picked rules"]="Khớp tất cả quy tắc",["Any picked rule"]="Khớp bất kỳ quy tắc",
    ["Always favorite"]="Luôn khóa loài này",["Favorite equipped"]="Khóa pet đang trang bị",
    ["FUSE MACHINE"]="MÁY DUNG HỢP",["No 3 matching pets"]="Chưa đủ 3 pet cùng loại",
    ["Auto fuse"]="Tự động dung hợp",["Fuse first"]="Ưu tiên dung hợp",
    ["Lowest rarity"]="Độ hiếm thấp nhất",["Highest rarity"]="Độ hiếm cao nhất",
    ["Use pets"]="Sử dụng pet",["Lowest value first"]="Giá trị thấp nhất trước",
    ["Highest value first"]="Giá trị cao nhất trước",["Skip mutated"]="Bỏ qua pet đột biến",
    ["Eject odd pets"]="Đẩy pet lẻ ra ngoài",["FUSE FILTER"]="BỘ LỌC DUNG HỢP",
    ["Only these pets"]="Chỉ những pet này",["Never fuse"]="Không bao giờ dung hợp",
    ["FUSE PREDICTOR"]="DỰ ĐOÁN DUNG HỢP",["SLOTS"]="Ô CHỨA",["STATUS"]="TRẠNG THÁI",
    ["Waiting for pets"]="Đang chờ pet",["LIKELY SIZE"]="KÍCH CỠ DỰ KIẾN",
    ["CHANCE"]="TỶ LỆ",["VALUE"]="GIÁ TRỊ",["BEST CASE"]="TỐT NHẤT CÓ THỂ",
    ["TASK ORDER"]="THỨ TỰ TÁC VỤ",["DOING"]="ĐANG LÀM",["WAITING"]="ĐANG CHỜ",
    ["Top goes first. A carried egg is always delivered first, and before the field opens every task waits in the safe zone."]="Mục ở trên làm trước. Trứng đang bê luôn được giao trước, và trước khi khu vực mở thì mọi tác vụ sẽ đợi ở vùng an toàn.",
    ["Steal filter eggs"]="Cướp trứng theo bộ lọc",["Shooting Star"]="Bắt Sao Băng",
    ["Racing Event"]="Sự Kiện Đua Xe",["Butterfly"]="Bắt Bướm",
    ["Steal wisp eggs"]="Cướp trứng Wisp",["Wisp"]="Nhặt Wisp",
    ["Steal missing index"]="Cướp trứng thiếu trong Chỉ mục",
    ["Steal lab eggs"]="Cướp trứng phòng Lab",["Place"]="Đặt trứng vào chuồng",
    ["Butterfly machine"]="Máy đổi Bướm",["Race"]="Đua Xe",["RACE"]="ĐUA XE",
    ["Star"]="Sao Băng",["STAR"]="SAO BĂNG",["BUTTERFLY"]="BẮT BƯỚM",
    ["Lab"]="Phòng Lab",["LAB"]="PHÒNG LAB",["AA"]="Admin (AA)",
    ["RACING EVENT"]="SỰ KIỆN ĐUA XE",["NEXT RACE"]="ĐUA TIẾP THEO",
    ["WINS"]="THẮNG",["TROPHIES"]="CÚP",["Auto race"]="Tự động đua xe",
    ["Race speed"]="Tốc độ đua",["Lower it if wins do not count"]="Giảm tốc độ nếu thắng không được tính",
    ["Use power-ups"]="Tự dùng vật phẩm tăng tốc",["REWARDS"]="PHẦN THƯỞNG",
    ["Auto claim rewards"]="Tự nhận phần thưởng",["Auto equip racer"]="Tự trang bị xe đua",
    ["Racer"]="Xe đua",["Best owned"]="Tốt nhất đang có",["Auto buy shop"]="Tự mua vật phẩm Shop",
    ["Shop items"]="Vật phẩm Shop",["SHOOTING STAR"]="SAO BĂNG RƠI",["LANDS IN"]="RƠI SAU",
    ["CATCH"]="BẮT SAO BĂNG",
    ["A Shooting Star is rare and only you can catch yours. It lands in Cosmic, runs from you, and needs a 1.6 s hold."]="Sao Băng rất hiếm và chỉ bạn mới bắt được của mình. Nó rơi ở khu Vũ Trụ (Cosmic), chạy trốn bạn và cần nhấn giữ 1.6 giây.",
    ["CAUGHT"]="ĐÃ BẮT",["EXPIRES IN"]="BIẾN MẤT SAU",
    ["SLIPPED"]="TUỘT MẤT",["TRIES"]="SỐ LẦN THỬ",["DISTANCE"]="KHOẢNG CÁCH",
    ["Auto catch shooting star"]="Tự động bắt sao băng",["BUTTERFLY BLOOM"]="MÙA BƯỚM NỞ",
    ["Auto butterfly bloom"]="Tự động bắt bướm",["EMERALD"]="LỤC BẢO",
    ["SAPPHIRE"]="LAM NGỌC",["AMETHYST"]="THẠCH ANH TÍM",["RADIANT"]="RỰC RỠ",
    ["ESSENCE"]="TINH CHẤT",["Catch mode"]="Chế độ bắt",["Stand"]="Đứng yên",
    ["Chase"]="Đuổi theo",["BUTTERFLY MACHINE"]="MÁY ĐỔI BƯỚM",
    ["Auto trade up"]="Tự nâng cấp bậc bướm",["Trade"]="Giao dịch đổi",
    ["Smart trade for essence"]="Đổi bướm lấy tinh chất thông minh",
    ["Auto craft essence"]="Tự chế tạo tinh chất",["WISP COMPANION"]="ĐỒNG HÀNH WISP",
    ["Catch priority"]="Ưu tiên bắt",["Rarest"]="Hiếm nhất",["Catch"]="Loại bướm bắt",
    ["Radiant"]="Rực Rỡ (Radiant)",["Catch speed"]="Tốc độ bắt",
    ["Auto wisp quest"]="Tự làm nhiệm vụ Wisp",["Auto banjo cricket"]="Tự bắt dế Banjo",
    ["STAGE"]="GIAI ĐOẠN",["LAB ODDS"]="TỶ LỆ PHÒNG LAB",["BANNER"]="BĂNG RÔN",
    ["ENDS IN"]="KẾT THÚC SAU",["BANNER CHANCE"]="TỶ LỆ BĂNG RÔN",["NEXT"]="TIẾP THEO",
    ["Experimental Pets"]="Pet Thí Nghiệm",["Biohazard Pets"]="Pet Sinh Học",
    ["Lab banners"]="Băng rôn phòng Lab",["Auto trade in"]="Tự động đổi trứng Lab",
    ["Auto reroll recipe"]="Tự đổi lại công thức",["Place lab reward eggs"]="Đặt trứng thưởng từ Lab",
    ["ADMIN ABUSE"]="LẠM DỤNG ADMIN (ABUSE)",["No admin boost right now"]="Hiện không có buff Admin nào",
    ["Instant steal (Admin Treadmill)"]="Cướp tức thì (Máy tập Admin)",
    ["Use admin treadmill"]="Tự dùng máy tập Admin",["CAPTURE THE EGG"]="CƯỚP TRỨNG SỰ KIỆN",
    ["Auto capture event egg"]="Tự bắt trứng sự kiện",
    ["Take it from the holder"]="Giật trứng từ người đang cầm",
    ["Hold height"]="Độ cao giữ trứng",["Keep away"]="Khoảng cách né tránh",
    ["MINIGAME EGGS"]="TRỨNG MINIGAME",
    ["Waiting for Red Light Green Light or T-Rex Run"]="Đang chờ Đèn Đỏ Đèn Xanh hoặc Chạy Trốn T-Rex",
    ["Auto steal minigame egg"]="Tự cướp trứng Minigame",["Player"]="Người Chơi",
    ["ESP"]="Định Vị (ESP)",["Move"]="Di Chuyển",["MOVE"]="DI CHUYỂN",
    ["Combat"]="Chiến Đấu",["COMBAT"]="CHIẾN ĐẤU",["FIELD EGGS"]="TRỨNG NGOÀI SÂN",
    ["Egg ESP"]="ESP Trứng",["Show"]="Hiển thị",["Name"]="Tên",
    ["Fixed size"]="Cố định kích cỡ",["OTHERS"]="MỤC KHÁC",
    ["Pen egg ESP"]="ESP trứng trong chuồng",["Other pens ESP"]="ESP chuồng người khác",
    ["Guard ESP"]="ESP Vệ sĩ",["Player ESP"]="ESP Người chơi",["ESP size"]="Kích cỡ ESP",
    ["MOVEMENT"]="TỐC ĐỘ & DI CHUYỂN",["Speed boost"]="Tăng tốc chạy",
    ["Boost speed"]="Tốc độ tăng thêm",["Infinite jump"]="Nhảy vô hạn",
    ["God mode"]="Bất tử (God mode)",["PROTECTION"]="BẢO VỆ NHÂN VẬT",
    ["Anti ragdoll"]="Chống ngã (Anti Ragdoll)",["Ignore traps"]="Bỏ qua bẫy",
    ["Instant prompts"]="Tương tác nhấn giữ tức thì",["Anti AFK"]="Chống treo máy (Anti AFK)",
    ["Invisible"]="Tàng hình",["AUTO HIT"]="TỰ ĐỘNG ĐÁNH",["Auto hit"]="Tự động đánh",
    ["Hit who"]="Mục tiêu đánh",["Nearest player"]="Người chơi gần nhất",
    ["Chosen player"]="Người chơi chỉ định",["Chase speed"]="Tốc độ đuổi theo",
    ["HIT AURA"]="VÒNG ĐÁNH TỰ ĐỘNG",["Hit aura"]="Vòng đánh tự động (Hit Aura)",
    ["Skip friends"]="Bỏ qua bạn bè",["WEAPONS"]="VŨ KHÍ",["Use weapons"]="Sử dụng vũ khí",
    ["Hold each"]="Thời gian cầm mỗi món",["System"]="Hệ Thống",["Server"]="Máy Chủ",
    ["SERVER"]="MÁY CHỦ",["Webhook"]="Webhook",["WEBHOOK"]="WEBHOOK",
    ["Optimizer"]="Tối Ưu Hóa",["OPTIMIZER"]="TỐI ƯU HÓA (GIẢM LAG)",
    ["Interface"]="Giao Diện",["Config"]="Cấu Hình",["Hop to"]="Chuyển tới server",
    ["Least players"]="Ít người chơi nhất",["Hop server"]="Đổi máy chủ",["Hop"]="Đổi ngay",
    ["Rejoin this server"]="Vào lại máy chủ này",["Copy"]="Sao chép",
    ["JOIN AND STAY"]="VÀO PHÒNG & DUY TRÌ",["Job ID"]="Mã phòng (Job ID)",
    ["Paste a Job ID"]="Dán mã Job ID vào đây",["Join that server"]="Vào máy chủ đó",
    ["Join"]="Vào ngay",["Rejoin on kick"]="Tự vào lại khi bị văng/kick",
    ["Auto load script"]="Tự chạy lại script khi chuyển server",
    ["DISCORD WEBHOOK"]="WEBHOOK TELEGRAM",["Webhook URL"]="Đường dẫn Webhook",
    ["Ping everyone"]="Tag @everyone",["WHAT TO POST"]="NỘI DUNG GỬI BÁO CÁO",
    ["Post stolen eggs"]="Báo cáo trứng cướp được",["Post fused eggs"]="Báo cáo trứng dung hợp",
    ["POSTED"]="ĐÃ GỬI",["Send a test post"]="Gửi tin nhắn thử nghiệm",
    ["Test"]="Thử nghiệm",["Post when bag is full"]="Gửi thông báo khi đầy túi",
    ["Ping user ID"]="Ping User ID",["Discord user ID"]="Nhập Telegram User ID",
    ["Ping role ID"]="Ping Role ID",["Discord role ID"]="Nhập Telegram Role ID",
    ["GRAPHICS"]="ĐỒ HỌA",["Low graphics"]="Đồ họa thấp (Tăng FPS)",
    ["Disable 3D Render"]="Tắt kết xuất 3D (Treo máy)",["Background color"]="Màu nền màn hình",
    ["Black"]="Màu Đen",["White"]="Màu Trắng",["Hide game UI"]="Ẩn giao diện gốc của Game",
    ["FRAME RATE"]="TỐC ĐỘ KHUNG HÌNH (FPS)",["FPS cap"]="Giới hạn FPS",
    ["Show FPS and ping"]="Hiện chỉ số FPS và Ping",["BASES"]="CĂN CỨ (BASES)",
    ["Hide other players' pets and eggs"]="Ẩn pet và trứng của người chơi khác",
    ["Hide my pets and eggs"]="Ẩn pet và trứng của bản thân",
    ["Common"]="Phổ Thông (Common)",["Uncommon"]="Thường (Uncommon)",["Rare"]="Hiếm (Rare)",
    ["Epic"]="Sử Thi (Epic)",["Legendary"]="Huyền Thoại (Legendary)",
    ["Mythic"]="Thần Thoại (Mythic)",["Cosmic"]="Vũ Trụ (Cosmic)",
    ["Secret"]="Bí Ẩn (Secret)",["Divine"]="Thánh Thần (Divine)",
    ["Eternal"]="Vĩnh Cửu (Eternal)",
    ["COMMON"]="PHỔ THÔNG",["UNCOMMON"]="THƯỜNG",["RARE"]="HIẾM",["EPIC"]="SỬ THI",
    ["LEGENDARY"]="HUYỀN THOẠI",["MYTHIC"]="THẦN THOẠI",["COSMIC"]="VŨ TRỤ",
    ["SECRET"]="BÍ ẨN",["DIVINE"]="THÁNH THẦN",["ETERNAL"]="VĨNH CỬU",
    -- HALLOWEEN
    ["HALLOWEEN DIMENSION"]="CHIỀU KHÔNG GIAN HALLOWEEN",
    ["Auto steal Halloween eggs"]="Tự động cướp trứng Halloween",
    ["Instant steal Halloween eggs"]="Cướp trứng Halloween tức thì",
    ["Steal speed"]="Tốc độ cướp",["Halloween eggs"]="Trứng Halloween",
    ["Halloween rarities"]="Độ hiếm Halloween",["Auto Pumpkin Moon"]="Tự động Pumpkin Moon",
    ["Auto buy Halloween Dimension Egg"]="Tự mua trứng Halloween Dimension",
    ["Walk speed"]="Tốc độ đi bộ",["MONSTERS"]="QUÁI VẬT",
    ["Auto farm monsters"]="Tự động farm quái vật",["Monster order"]="Thứ tự quái vật",
    ["PHANTOM EXPRESS"]="TÀU MA (PHANTOM EXPRESS)",["TRAIN"]="TÀU",["SOULS"]="LINH HỒN",
    ["Not here"]="Không ở đây",["Auto Phantom Express"]="Tự động Phantom Express",
    ["Auto vacuum Ghouler boss"]="Tự hút boss Ghouler",["Ghost target"]="Mục tiêu ma",
    ["Rarest first"]="Hiếm nhất trước",["Auto trade souls"]="Tự động đổi linh hồn",
    ["GHOST DOG AND FISHING"]="CHÓ MA VÀ CÂU CÁ",["QUEST"]="NHIỆM VỤ",
    ["FISH CAUGHT"]="CÁ ĐÃ BẮT",["Done"]="Hoàn thành",
    ["Auto Ghost Dog quest"]="Tự làm nhiệm vụ Chó Ma",["Auto fishing"]="Tự động câu cá",
    ["Cast luck"]="Độ may mắn câu",["x1.5 Perfect"]="x1.5 Hoàn hảo",
    ["CURSED ISLAND WARS"]="ĐẢO NGUYỀN RỦA (ISLAND WARS)",
    ["Auto play Cursed Island Wars"]="Tự động chơi Cursed Island Wars",
    ["Island Wars target"]="Mục tiêu Island Wars",["Enemies and base"]="Kẻ thù và căn cứ",
    ["Teleport zones"]="Dịch chuyển theo khu vực",["Delivery speed"]="Tốc độ giao trứng",
    ["Change if steal fails"]="Thay đổi nếu cướp thất bại",
    ["Steal from other players"]="Cướp từ người chơi khác",
    ["Instant steal"]="Cướp tức thì",["Admin treadmill"]="Máy tập Admin",
    -- CONFIG
    ["CONFIG"]="CẤU HÌNH",["PROFILES"]="HỒ SƠ CẤU HÌNH",["ACTIVE"]="ĐANG DÙNG",
    ["SAVED CONFIGS"]="CẤU HÌNH ĐÃ LƯU",["New config name"]="Tên cấu hình mới",
    ["Auto if empty"]="Tự đặt tên nếu trống",["Create config"]="Tạo cấu hình",
    ["Create"]="Tạo",["Pick to delete"]="Chọn để xóa",["Delete picked"]="Xóa đã chọn",
    ["Delete"]="Xóa",["Restore deleted"]="Khôi phục đã xóa",["Export config"]="Xuất cấu hình",
    ["Import text"]="Nhập văn bản",["Paste config text"]="Dán văn bản cấu hình vào đây",
    ["Import config"]="Nhập cấu hình",["Import"]="Nhập",
    ["Set as active config"]="Đặt làm cấu hình đang dùng",["Set active"]="Đặt làm chính",
    ["Save changes"]="Lưu thay đổi",["Save"]="Lưu",
    ["Auto load"]="Tự động tải",["Auto save"]="Tự động lưu",
    -- INTERFACE
    ["INTERFACE"]="GIAO DIỆN",["UI scale"]="Tỷ lệ giao diện",
    ["Show / hide UI"]="Hiện / Ẩn giao diện",["Opacity"]="Độ mờ",
    ["Tone"]="Tông màu",["Dim the game"]="Làm tối màn hình game",["THEME"]="CHỦ ĐỀ MÀU",
    ["Twilight"]="Hoàng Hôn",["Aurora"]="Cực Quang",["Ocean"]="Đại Dương",
    ["Midnight"]="Nửa Đêm",["Sakura"]="Hoa Anh Đào",["Onyx"]="Đá Onyx",["Mono"]="Đơn Sắc",
    ["GAME HUD"]="HUD GAME",["Steal panel button on game HUD"]="Nút bảng Cướp trên HUD game",
    ["DEFAULTS"]="MẶC ĐỊNH",["Reset to defaults"]="Đặt lại mặc định",["Reset"]="Đặt lại",
    ["Turn off all toggles"]="Tắt tất cả công tắc",["Turn off"]="Tắt hết",
    ["QUICK BARS"]="THANH NHANH",["Show quick bars"]="Hiển thị thanh nhanh",
    ["Keybinds"]="Phím tắt",["Bar size"]="Kích thước thanh",
    ["PINS AND KEYBINDS"]="GHIM & PHÍM TẮT",["Find an option"]="Tìm tùy chọn",
    ["All"]="Tất cả",["Pinned"]="Đã ghim",
    ["Clear all quick bars"]="Xóa tất cả thanh nhanh",["Clear all keybinds"]="Xóa tất cả phím tắt",
    ["Instant steps"]="Bước tức thì",["STEAL / AUTO STEAL"]="CƯỚP / TỰ ĐỘNG CƯỚP",
    ["slider"]="thanh trượt",["+ PIN"]="+ GHIM",
    -- Steal Panel
    ["Steal Panel"]="Bảng Cướp Trứng",
    ["STEAL"]="CƯỚP",
    ["Auto Steal: ON"]="Tự Động Cướp: BẬT",
    ["Auto Steal: OFF"]="Tự Động Cướp: TẮT",
    ["Halloween: ON"]="Halloween: BẬT",
    ["Halloween: OFF"]="Halloween: TẮT",
    ["Eggs: All"]="Trứng: Tất Cả",
    ["Eggs: Filter"]="Trứng: Lọc",
    -- Chilli Finder
    ["Chilli Finder"]="Tìm Máy Chủ",
    ["AUTO OFF"]="TỰ ĐỘNG TẮT",
    ["AUTO ON"]="TỰ ĐỘNG BẬT",
    ["FORCE JOIN"]="VÀO NGAY",
    ["MIN VALUE"]="GIÁ TRỊ TỐI THIỂU",
    ["RARITY"]="ĐỘ HIẾM",
    ["ACCOUNT"]="TÀI KHOẢN",
    ["Any"]="Bất Kỳ",
    ["No plan"]="Chưa đăng ký",
    ["Active"]="Đang hoạt động",
    ["Join"]="Vào",
    -- Trạng thái chung
    ["Enabled"]="Đã bật",
    ["Disabled"]="Đã tắt",
    ["ON"]="BẬT",
    ["Loading..."]="Đang tải...",
    ["Please wait..."]="Vui lòng chờ...",
    ["Copied!"]="Đã chép!",
    ["Click to copy"]="Nhấn để chép",
    ["Success"]="Thành công",
    ["Error"]="Lỗi",
    ["No servers found"]="Không tìm thấy máy chủ",
    ["No results"]="Không có kết quả",
    -- Gói tài khoản
    ["Premium"]="Premium",
    ["Basic"]="Cơ bản",
    ["Pro"]="Pro",
    ["Key"]="Key",
    -- Thời gian từ (dạng đầy đủ)
    ["just now"]="vừa xong",
    ["Just now"]="Vừa xong",
    ["1 second ago"]="1 giây trước",
    ["1 minute ago"]="1 phút trước",
    ["1 hour ago"]="1 giờ trước",
    ["1 day ago"]="1 ngày trước",
    -- Trạng thái kết nối
    ["Connected"]="Đã kết nối",
    ["Disconnected"]="Mất kết nối",
    ["Not connected"]="Chưa kết nối",
    -- Thông báo hay gặp
    ["None selected"]="Chưa chọn",
    ["Select one"]="Chọn một",
    ["No items"]="Không có mục nào",
    ["Confirm"]="Xác nhận",
    ["Cancel"]="Hủy",
    ["Apply"]="Áp dụng",
    ["Close"]="Đóng",
    ["Open"]="Mở",
    ["Back"]="Quay lại",
    ["Next"]="Tiếp",
    ["Done"]="Xong",
    ["Retry"]="Thử lại",
    ["Refresh"]="Làm mới",
    ["Update"]="Cập nhật",
    -- Cướp / event
    ["Waiting for event"]="Đang chờ sự kiện",
    ["Event ended"]="Sự kiện đã kết thúc",
    ["Event starting"]="Sự kiện sắp bắt đầu",
    ["No egg to steal"]="Không có trứng để cướp",
    ["Bag full"]="Đầy túi",
    ["Sold"]="Đã bán",
    ["Placed"]="Đã đặt",
    ["Hatched"]="Đã ấp",
}

-- ---- EXACT ID (from TLN_CHEAT_FULL) ----
local EXACT_MATCH_ID = {
    ["Idle"]="Menganggur",["Waiting"]="Menunggu",["Nothing"]="Tidak ada",
    ["Waiting in safe zone"]="Menunggu di zona aman",["Returning to safe zone"]="Kembali ke zona aman",
    ["Returning home"]="Kembali ke rumah",["Going home"]="Pulang ke rumah",
    ["Delivering egg"]="Mengantarkan telur",["Dropping egg"]="Menjatuhkan telur",
    ["Dropping eggs"]="Menjatuhkan telur",["Selling eggs"]="Menjual telur",
    ["Selling pets"]="Menjual pet",["Selling lab eggs"]="Menjual telur Lab",
    ["Hatching eggs"]="Menetaskan telur",["Placing eggs"]="Menempatkan telur",
    ["Mutating eggs"]="Mutasi telur",["Fusing pets"]="Menggabungkan pet",
    ["Hopping server"]="Pindah server",["Rejoining"]="Bergabung kembali",
    ["Avoiding guard"]="Menghindari penjaga",["Evading guard"]="Menghindari penjaga",
    ["Using treadmill"]="Menggunakan treadmill",["Upgrading treadmill"]="Meningkatkan treadmill",
    ["Upgrading base"]="Meningkatkan markas",["Claiming rewards"]="Mengklaim hadiah",
    ["Claiming offline cash"]="Mengklaim uang offline",["Catching shooting star"]="Menangkap bintang jatuh",
    ["Catching butterfly"]="Menangkap kupu-kupu",["Joining race"]="Bergabung balapan",
    ["Racing"]="Sedang balapan",["Home"]="Beranda",["Dashboard"]="Dasbor",
    ["Welcome back"]="Selamat datang kembali",["TLN CHEAT Discord"]="TLN CHEAT Discord",
    ["Updates, keys, support"]="Update, kunci, dukungan",["Copy Invite"]="Salin Tautan Undangan",
    ["Discord"]="Discord",["MONEY /S"]="UANG /DETIK",["OPEN"]="BUKA",
    ["Welcome to TLN CHEAT 1.0.0! Join our Discord for updates and support"]="Selamat datang di TLN CHEAT! Bergabunglah ke Discord untuk update dan dukungan",
    ["Beta version"]="Versi Beta",
    ["This is a test build. Features may change and bugs can happen."]="Ini versi percobaan. Fitur bisa berubah dan bug bisa terjadi.",
    ["Rejoin"]="Gabung Lagi",["Server hop"]="Pindah Server",["Copy Job ID"]="Salin Job ID",
    ["Unload hub"]="Tutup Hub",["Save config"]="Simpan konfigurasi",["Hide UI"]="Sembunyikan Menu",
    ["SESSION"]="SESI",["STOLEN"]="DICURI",["LAST EGG"]="TELUR TERAKHIR",
    ["PLACED"]="DITEMPATKAN",["HATCHED"]="DITETASKAN",["NIGHT IN"]="MALAM DALAM",
    ["SESSION TIME"]="WAKTU SESI",["BEST STEAL"]="CURIAN TERBAIK",
    ["EGG BAG"]="TAS TELUR",["PET BAG"]="TAS PET",["WHAT'S NEW"]="APA YANG BARU",
    ["NEW"]="BARU",["Event"]="Acara",["Search"]="Cari",["Filter"]="Filter",
    ["Steal"]="Curi Telur",["Auto Steal"]="Curi Otomatis",["AUTO STEAL"]="CURI OTOMATIS",
    ["Auto steal"]="Curi otomatis",["Egg Predictor"]="Prediksi Telur",
    ["EGG PREDICTOR"]="PREDIKSI TELUR",["Go to egg"]="Pergi ke telur",
    ["Teleport to egg"]="Teleport ke telur",["Tween"]="Terbang (Tween)",
    ["Delivery method"]="Metode pengiriman",["Fast tween speed"]="Kecepatan terbang cepat",
    ["Tween speed"]="Kecepatan terbang",["Steal missing index eggs"]="Curi telur indeks yang kurang",
    ["Steal back from players"]="Curi kembali dari pemain",["Anti guard"]="Anti penjaga",
    ["Drop eggs at safe zone"]="Jatuhkan telur di zona aman",["FILTER"]="FILTER",
    ["Zones"]="Zona",["None"]="Tidak ada",["Steal first"]="Prioritas curi",
    ["Best value"]="Nilai tertinggi",["Lowest value"]="Nilai terendah",
    ["Best rarity"]="Kelangkaan terbaik",["Best mutation"]="Mutasi terbaik",
    ["Biggest"]="Terbesar",["Closest"]="Terdekat",
    ["Mutations"]="Mutasi",["Rarities"]="Kelangkaan",["Only these eggs"]="Hanya telur ini",
    ["Min value /s"]="Nilai minimum /d",["Off"]="Mati",
    ["Sell cheapest egg when bag is full"]="Jual telur termurah saat tas penuh",
    ["Keep lab eggs"]="Simpan telur Lab",["AUTO HOP SERVER"]="PINDAH SERVER OTOMATIS",
    ["Only sell eggs below /s"]="Jual telur di bawah /d saja",["EGG SHOWCASE"]="PAMERAN TELUR",
    ["Sort eggs"]="Urutkan telur",["Preview card"]="Kartu pratinjau",
    ["Pick one"]="Pilih satu",["Pick any"]="Pilih sembarang",["Value"]="Nilai",
    ["Rarity"]="Kelangkaan",["Time left"]="Sisa waktu",["Default"]="Bawaan",
    ["Clear"]="Hapus pilihan",["Select all"]="Pilih semua",["SIZE"]="UKURAN",
    ["WEIGHT"]="BERAT",["READY"]="SIAP",["IN BAG"]="DI TAS",
    ["GROWING"]="TUMBUH",["Hatch now"]="Tetaskan sekarang",["Hold egg"]="Pegang telur",
    ["Fly to egg"]="Terbang ke telur",
    ["Farm"]="Pertanian",["Pen"]="Kandang",["PEN"]="KANDANG",
    ["Treadmill"]="Treadmill",["TREADMILL"]="TREADMILL",["Mutate"]="Mutasi",
    ["MUTATE"]="MUTASI",["Sell"]="Jual",["SELL"]="JUAL OTOMATIS",
    ["Fuse"]="Gabung",["FUSE"]="GABUNGKAN",["Priority"]="Prioritas",
    ["PRIORITY"]="URUTAN PRIORITAS",["AUTO PLACE"]="TEMPATKAN OTOMATIS",
    ["Auto place"]="Tempatkan otomatis",["Place when"]="Tempatkan saat",["Always"]="Selalu",
    ["Place first"]="Prioritas tempatkan",["AUTO HATCH"]="TETASKAN OTOMATIS",
    ["Auto hatch"]="Tetaskan otomatis",["Equip best pets"]="Pasang pet terbaik",
    ["READY NOW"]="SIAP DITETASKAN",["Auto treadmill"]="Treadmill otomatis",
    ["Auto upgrade treadmill"]="Tingkatkan treadmill otomatis",["PROGRESS"]="PROGRES",
    ["Auto upgrade base"]="Tingkatkan markas otomatis",["Auto buy trails"]="Beli jejak otomatis",
    ["Auto claim offline cash"]="Klaim uang offline otomatis",
    ["Auto claim index rewards"]="Klaim hadiah indeks otomatis",["AUTO MUTATE"]="MUTASI OTOMATIS",
    ["Auto mutate"]="Mutasi otomatis",["MUTATE FILTER"]="FILTER MUTASI",
    ["Use items"]="Gunakan item",["Mutate first"]="Prioritas mutasi",
    ["Auto buy Nitro"]="Beli Nitro otomatis",["PETS"]="PET",["EGGS"]="TELUR",
    ["Auto sell pets"]="Jual pet otomatis",["Auto sell eggs"]="Jual telur otomatis",
    ["Sell rarities"]="Kelangkaan yang dijual",["Never sell"]="Jangan pernah jual",
    ["Only mutations"]="Hanya mutasi",["Only below /s"]="Hanya di bawah /d",
    ["Keep mutated"]="Simpan yang bermutasi",["Sell matching pets now"]="Jual pet yang cocok sekarang",
    ["Sell matching eggs now"]="Jual telur yang cocok sekarang",["LAB EGGS"]="TELUR LAB",
    ["FAVORITE"]="FAVORIT (KUNCI)",["Auto favorite"]="Favoritkan otomatis",
    ["Auto sell lab eggs"]="Jual telur Lab otomatis",
    ["Sell matching lab eggs now"]="Jual telur Lab yang cocok sekarang",["Match"]="Kondisi cocok",
    ["All picked rules"]="Semua aturan terpilih",["Any picked rule"]="Aturan apa pun terpilih",
    ["Always favorite"]="Selalu favoritkan spesies ini",["Favorite equipped"]="Favoritkan pet yang dipakai",
    ["FUSE MACHINE"]="MESIN GABUNG",["No 3 matching pets"]="Belum ada 3 pet yang cocok",
    ["Auto fuse"]="Gabung otomatis",["Fuse first"]="Prioritas gabung",
    ["Lowest rarity"]="Kelangkaan terendah",["Highest rarity"]="Kelangkaan tertinggi",
    ["Use pets"]="Gunakan pet",["Lowest value first"]="Nilai terendah dulu",
    ["Highest value first"]="Nilai tertinggi dulu",["Skip mutated"]="Lewati pet bermutasi",
    ["Eject odd pets"]="Keluarkan pet ganjil",["FUSE FILTER"]="FILTER GABUNG",
    ["Only these pets"]="Hanya pet ini",["Never fuse"]="Jangan pernah gabung",
    ["FUSE PREDICTOR"]="PREDIKSI GABUNG",["SLOTS"]="SLOT",["STATUS"]="STATUS",
    ["Waiting for pets"]="Menunggu pet",["LIKELY SIZE"]="UKURAN PERKIRAAN",
    ["CHANCE"]="PELUANG",["VALUE"]="NILAI",["BEST CASE"]="KASUS TERBAIK",
    ["TASK ORDER"]="URUTAN TUGAS",["DOING"]="SEDANG",["WAITING"]="MENUNGGU",
    ["Steal filter eggs"]="Curi telur dengan filter",["Shooting Star"]="Bintang Jatuh",
    ["Racing Event"]="Event Balapan",["Butterfly"]="Tangkap Kupu-kupu",
    ["Steal wisp eggs"]="Curi telur Wisp",["Wisp"]="Ambil Wisp",
    ["Steal missing index"]="Curi telur indeks yang kurang",
    ["Steal lab eggs"]="Curi telur Lab",["Place"]="Tempatkan telur di kandang",
    ["Butterfly machine"]="Mesin Kupu-kupu",["Race"]="Balapan",["RACE"]="BALAPAN",
    ["Star"]="Bintang Jatuh",["STAR"]="BINTANG JATUH",["BUTTERFLY"]="KUPU-KUPU",
    ["Lab"]="Lab",["LAB"]="LAB",["AA"]="Admin (AA)",
    ["RACING EVENT"]="EVENT BALAPAN",["NEXT RACE"]="BALAPAN BERIKUTNYA",
    ["WINS"]="MENANG",["TROPHIES"]="TROFI",["Auto race"]="Balapan otomatis",
    ["Race speed"]="Kecepatan balapan",["Lower it if wins do not count"]="Turunkan jika menang tidak dihitung",
    ["Use power-ups"]="Gunakan power-up otomatis",["REWARDS"]="HADIAH",
    ["Auto claim rewards"]="Klaim hadiah otomatis",["Auto equip racer"]="Pasang racer otomatis",
    ["Racer"]="Racer",["Best owned"]="Terbaik yang dimiliki",["Auto buy shop"]="Beli item toko otomatis",
    ["Shop items"]="Item toko",["SHOOTING STAR"]="BINTANG JATUH",["LANDS IN"]="MENDARAT DALAM",
    ["CATCH"]="TANGKAP",["CAUGHT"]="TERTANGKAP",["EXPIRES IN"]="KEDALUWARSA DALAM",
    ["SLIPPED"]="TERLEWAT",["TRIES"]="PERCOBAAN",["DISTANCE"]="JARAK",
    ["Auto catch shooting star"]="Tangkap bintang jatuh otomatis",["BUTTERFLY BLOOM"]="MEKAR KUPU-KUPU",
    ["Auto butterfly bloom"]="Tangkap kupu-kupu otomatis",["EMERALD"]="ZAMRUD",
    ["SAPPHIRE"]="SAFIR",["AMETHYST"]="AMETIS",["RADIANT"]="BERCAHAYA",
    ["ESSENCE"]="ESENSI",["Catch mode"]="Mode tangkap",["Stand"]="Diam",
    ["Chase"]="Kejar",["BUTTERFLY MACHINE"]="MESIN KUPU-KUPU",
    ["Auto trade up"]="Tingkatkan kupu-kupu otomatis",["Trade"]="Tukar",
    ["Smart trade for essence"]="Tukar kupu-kupu untuk esensi cerdas",
    ["Auto craft essence"]="Buat esensi otomatis",["WISP COMPANION"]="TEMAN WISP",
    ["Catch priority"]="Prioritas tangkap",["Rarest"]="Paling langka",["Catch"]="Jenis kupu-kupu",
    ["Radiant"]="Bercahaya (Radiant)",["Catch speed"]="Kecepatan tangkap",
    ["Auto wisp quest"]="Quest Wisp otomatis",["Auto banjo cricket"]="Tangkap jangkrik Banjo otomatis",
    ["STAGE"]="TAHAP",["LAB ODDS"]="PELUANG LAB",["BANNER"]="BANNER",
    ["ENDS IN"]="BERAKHIR DALAM",["BANNER CHANCE"]="PELUANG BANNER",["NEXT"]="BERIKUTNYA",
    ["Experimental Pets"]="Pet Eksperimental",["Biohazard Pets"]="Pet Biohazard",
    ["Lab banners"]="Banner Lab",["Auto trade in"]="Tukar telur Lab otomatis",
    ["Auto reroll recipe"]="Acak ulang resep otomatis",["Place lab reward eggs"]="Tempatkan telur hadiah Lab",
    ["ADMIN ABUSE"]="PENYALAHGUNAAN ADMIN",["No admin boost right now"]="Tidak ada buff Admin saat ini",
    ["Instant steal (Admin Treadmill)"]="Curi instan (Treadmill Admin)",
    ["Use admin treadmill"]="Gunakan treadmill Admin",["CAPTURE THE EGG"]="REBUT TELUR EVENT",
    ["Auto capture event egg"]="Rebut telur event otomatis",
    ["Take it from the holder"]="Ambil dari yang memegang",
    ["Hold height"]="Ketinggian pegang telur",["Keep away"]="Jarak menghindari",
    ["MINIGAME EGGS"]="TELUR MINIGAME",
    ["Waiting for Red Light Green Light or T-Rex Run"]="Menunggu Lampu Merah Hijau atau Lari T-Rex",
    ["Auto steal minigame egg"]="Curi telur Minigame otomatis",["Player"]="Pemain",
    ["ESP"]="ESP",["Move"]="Bergerak",["MOVE"]="BERGERAK",
    ["Combat"]="Tempur",["COMBAT"]="TEMPUR",["FIELD EGGS"]="TELUR LAPANGAN",
    ["Egg ESP"]="ESP Telur",["Show"]="Tampilkan",["Name"]="Nama",
    ["Fixed size"]="Ukuran tetap",["OTHERS"]="LAINNYA",
    ["Pen egg ESP"]="ESP telur kandang",["Other pens ESP"]="ESP kandang pemain lain",
    ["Guard ESP"]="ESP Penjaga",["Player ESP"]="ESP Pemain",["ESP size"]="Ukuran ESP",
    ["MOVEMENT"]="KECEPATAN & GERAK",["Speed boost"]="Percepat lari",
    ["Boost speed"]="Tambah kecepatan",["Infinite jump"]="Lompat tak terbatas",
    ["God mode"]="Mode dewa (God mode)",["PROTECTION"]="PERLINDUNGAN KARAKTER",
    ["Anti ragdoll"]="Anti jatuh",["Ignore traps"]="Abaikan jebakan",
    ["Instant prompts"]="Interaksi tahan langsung",["Anti AFK"]="Anti AFK",
    ["Invisible"]="Tidak terlihat",["AUTO HIT"]="SERANG OTOMATIS",["Auto hit"]="Serang otomatis",
    ["Hit who"]="Target serang",["Nearest player"]="Pemain terdekat",
    ["Chosen player"]="Pemain yang dipilih",["Chase speed"]="Kecepatan kejar",
    ["HIT AURA"]="AURA SERANG",["Hit aura"]="Aura serang otomatis",
    ["Skip friends"]="Lewati teman",["WEAPONS"]="SENJATA",["Use weapons"]="Gunakan senjata",
    ["Hold each"]="Waktu pegang tiap item",["System"]="Sistem",["Server"]="Server",
    ["SERVER"]="SERVER",["Webhook"]="Webhook",["WEBHOOK"]="WEBHOOK",
    ["Optimizer"]="Pengoptimal",["OPTIMIZER"]="PENGOPTIMAL (KURANGI LAG)",
    ["Interface"]="Antarmuka",["Config"]="Konfigurasi",["Hop to"]="Pindah ke server",
    ["Least players"]="Pemain paling sedikit",["Hop server"]="Pindah server",["Hop"]="Pindah sekarang",
    ["Rejoin this server"]="Bergabung kembali ke server ini",["Copy"]="Salin",
    ["JOIN AND STAY"]="BERGABUNG & TETAP",["Job ID"]="Job ID",
    ["Paste a Job ID"]="Tempel Job ID di sini",["Join that server"]="Masuk server itu",
    ["Join"]="Masuk sekarang",["Rejoin on kick"]="Gabung lagi saat dikick",
    ["Auto load script"]="Muat ulang script saat pindah server",
    ["DISCORD WEBHOOK"]="WEBHOOK DISCORD",["Webhook URL"]="URL Webhook",
    ["Ping everyone"]="Tag @everyone",["WHAT TO POST"]="ISI LAPORAN",
    ["Post stolen eggs"]="Laporkan telur yang dicuri",["Post fused eggs"]="Laporkan telur yang digabung",
    ["POSTED"]="TERKIRIM",["Send a test post"]="Kirim pesan uji",
    ["Test"]="Uji coba",["Post when bag is full"]="Kirim notif saat tas penuh",
    ["Ping user ID"]="Ping User ID",["Discord user ID"]="Masukkan Discord User ID",
    ["Ping role ID"]="Ping Role ID",["Discord role ID"]="Masukkan Discord Role ID",
    ["GRAPHICS"]="GRAFIS",["Low graphics"]="Grafis rendah (Tingkatkan FPS)",
    ["Disable 3D Render"]="Matikan render 3D (AFK)",["Background color"]="Warna latar layar",
    ["Black"]="Hitam",["White"]="Putih",["Hide game UI"]="Sembunyikan UI bawaan game",
    ["FRAME RATE"]="KECEPATAN FRAME (FPS)",["FPS cap"]="Batas FPS",
    ["Show FPS and ping"]="Tampilkan FPS dan Ping",["BASES"]="MARKAS",
    ["Hide other players' pets and eggs"]="Sembunyikan pet dan telur pemain lain",
    ["Hide my pets and eggs"]="Sembunyikan pet dan telur sendiri",
    ["Common"]="Umum (Common)",["Uncommon"]="Tidak Umum (Uncommon)",["Rare"]="Langka (Rare)",
    ["Epic"]="Epik (Epic)",["Legendary"]="Legendaris (Legendary)",
    ["Mythic"]="Mitos (Mythic)",["Cosmic"]="Kosmik (Cosmic)",
    ["Secret"]="Rahasia (Secret)",["Divine"]="Ilahi (Divine)",["Eternal"]="Abadi (Eternal)",
    ["COMMON"]="UMUM",["UNCOMMON"]="TIDAK UMUM",["RARE"]="LANGKA",["EPIC"]="EPIK",
    ["LEGENDARY"]="LEGENDARIS",["MYTHIC"]="MITOS",["COSMIC"]="KOSMIK",
    ["SECRET"]="RAHASIA",["DIVINE"]="ILAHI",["ETERNAL"]="ABADI",
    ["HALLOWEEN DIMENSION"]="DIMENSI HALLOWEEN",
    ["Auto steal Halloween eggs"]="Curi telur Halloween otomatis",
    ["Instant steal Halloween eggs"]="Curi telur Halloween instan",
    ["Steal speed"]="Kecepatan curi",["Halloween eggs"]="Telur Halloween",
    ["Halloween rarities"]="Kelangkaan Halloween",["Auto Pumpkin Moon"]="Pumpkin Moon otomatis",
    ["Auto buy Halloween Dimension Egg"]="Beli telur Halloween Dimension otomatis",
    ["Walk speed"]="Kecepatan jalan",["MONSTERS"]="MONSTER",
    ["Auto farm monsters"]="Farm monster otomatis",["Monster order"]="Urutan monster",
    ["PHANTOM EXPRESS"]="KERETA HANTU (PHANTOM EXPRESS)",["TRAIN"]="KERETA",["SOULS"]="JIWA",
    ["Not here"]="Tidak di sini",["Auto Phantom Express"]="Phantom Express otomatis",
    ["Auto vacuum Ghouler boss"]="Hisap boss Ghouler otomatis",["Ghost target"]="Target hantu",
    ["Rarest first"]="Paling langka dulu",["Auto trade souls"]="Tukar jiwa otomatis",
    ["GHOST DOG AND FISHING"]="ANJING HANTU DAN MEMANCING",["QUEST"]="MISI",
    ["FISH CAUGHT"]="IKAN DITANGKAP",["Done"]="Selesai",
    ["Auto Ghost Dog quest"]="Misi Anjing Hantu otomatis",["Auto fishing"]="Memancing otomatis",
    ["Cast luck"]="Keberuntungan lempar",["x1.5 Perfect"]="x1.5 Sempurna",
    ["CURSED ISLAND WARS"]="PERANG PULAU TERKUTUK",
    ["Auto play Cursed Island Wars"]="Main Perang Pulau Terkutuk otomatis",
    ["Island Wars target"]="Target Perang Pulau",["Enemies and base"]="Musuh dan markas",
    ["Teleport zones"]="Teleport per zona",["Delivery speed"]="Kecepatan antar telur",
    ["Change if steal fails"]="Ganti jika curi gagal",
    ["Steal from other players"]="Curi dari pemain lain",
    ["Instant steal"]="Curi instan",["Admin treadmill"]="Treadmill Admin",
    ["CONFIG"]="KONFIGURASI",["PROFILES"]="PROFIL KONFIGURASI",["ACTIVE"]="AKTIF",
    ["SAVED CONFIGS"]="KONFIGURASI TERSIMPAN",["New config name"]="Nama konfigurasi baru",
    ["Auto if empty"]="Otomatis jika kosong",["Create config"]="Buat konfigurasi",
    ["Create"]="Buat",["Pick to delete"]="Pilih untuk hapus",
    ["Delete picked"]="Hapus yang dipilih",["Delete"]="Hapus",
    ["Restore deleted"]="Pulihkan yang dihapus",["Export config"]="Ekspor konfigurasi",
    ["Import text"]="Impor teks",["Paste config text"]="Tempel teks konfigurasi di sini",
    ["Import config"]="Impor konfigurasi",["Import"]="Impor",
    ["Set as active config"]="Jadikan konfigurasi aktif",["Set active"]="Jadikan aktif",
    ["Save changes"]="Simpan perubahan",["Save"]="Simpan",
    ["Auto load"]="Muat otomatis",["Auto save"]="Simpan otomatis",
    ["INTERFACE"]="ANTARMUKA",["UI scale"]="Skala antarmuka",
    ["Show / hide UI"]="Tampilkan / Sembunyikan antarmuka",["Opacity"]="Opasitas",
    ["Tone"]="Nada warna",["Dim the game"]="Gelapkan layar game",["THEME"]="TEMA WARNA",
    ["Twilight"]="Senja",["Aurora"]="Aurora",["Ocean"]="Samudra",
    ["Midnight"]="Tengah Malam",["Sakura"]="Sakura",["Onyx"]="Onyx",["Mono"]="Mono",
    ["GAME HUD"]="HUD GAME",["Steal panel button on game HUD"]="Tombol panel Curi di HUD game",
    ["DEFAULTS"]="BAWAAN",["Reset to defaults"]="Setel ulang ke bawaan",
    ["Reset"]="Setel Ulang",["Turn off all toggles"]="Matikan semua toggle",
    ["Turn off"]="Matikan semua",["QUICK BARS"]="BILAH CEPAT",
    ["Show quick bars"]="Tampilkan bilah cepat",["Keybinds"]="Pintasan tombol",
    ["Bar size"]="Ukuran bilah",["PINS AND KEYBINDS"]="PIN & PINTASAN",
    ["Find an option"]="Cari opsi",["All"]="Semua",["Pinned"]="Disematkan",
    ["Clear all quick bars"]="Hapus semua bilah cepat",["Clear all keybinds"]="Hapus semua pintasan",
    ["Instant steps"]="Langkah instan",["STEAL / AUTO STEAL"]="CURI / CURI OTOMATIS",
    ["Ping user ID"]="Ping User ID",["Discord user ID"]="Masukkan Discord User ID",
    ["Ping role ID"]="Ping Role ID",["Discord role ID"]="Masukkan Discord Role ID",
}

-- ---- PATTERNS ID (from TLN_CHEAT_FULL) ----
local STATUS_ACTION_PATTERNS_ID = {
    {pat="^[Cc]arrying (.+) to safe zone$",rep="Membawa %1 ke zona aman"},
    {pat="^[Cc]arrying (.+) to base$",rep="Membawa %1 ke markas"},
    {pat="^[Cc]arrying (.+) to pen$",rep="Membawa %1 ke kandang"},
    {pat="^[Cc]arrying (.+) home$",rep="Membawa %1 ke rumah"},
    {pat="^[Cc]arrying (.+)$",rep="Membawa %1"},
    {pat="^[Dd]elivering (.+) to (.+)$",rep="Mengantarkan %1 ke %2"},
    {pat="^[Dd]elivering (.+) home$",rep="Mengantarkan %1 ke rumah"},
    {pat="^[Dd]elivering (.+)$",rep="Mengantarkan %1"},
    {pat="^[Ss]tealing (.+) from (.+)$",rep="Mencuri %1 dari %2"},
    {pat="^[Ss]tealing (.+)$",rep="Mencuri %1"},
    {pat="^[Tt]weening to (.+)$",rep="Terbang ke %1"},
    {pat="^[Tt]eleporting to (.+)$",rep="Teleport ke %1"},
    {pat="^[Gg]oing to (.+)$",rep="Pergi ke %1"},
    {pat="^[Mm]oving to (.+)$",rep="Bergerak ke %1"},
    {pat="^[Pp]lacing (.+)$",rep="Menempatkan %1"},
    {pat="^[Hh]atching (.+)$",rep="Menetaskan %1"},
    {pat="^[Ss]elling (.+)$",rep="Menjual %1"},
    {pat="^[Ff]using (.+)$",rep="Menggabungkan %1"},
    {pat="^[Cc]atching (.+)$",rep="Menangkap %1"},
    {pat="^[Ww]aiting for (.+)$",rep="Menunggu %1"},
}
local FALLBACK_VERB_PREFIX_ID = {
    ["Carrying "]="Membawa ",["Delivering "]="Mengantarkan ",["Stealing "]="Mencuri ",
    ["Going "]="Pergi ",["Tweening "]="Terbang ",["Teleporting "]="Teleport ke ",
    ["Moving "]="Bergerak ",["Placing "]="Menempatkan ",["Hatching "]="Menetaskan ",
    ["Mutating "]="Mutasi ",["Selling "]="Menjual ",["Fusing "]="Menggabungkan ",
    ["Catching "]="Menangkap ",["Waiting "]="Menunggu ",["Claiming "]="Mengklaim ",
    ["Upgrading "]="Meningkatkan ",["Buying "]="Membeli ",["Collecting "]="Mengumpulkan ",
    ["Dropping "]="Menjatuhkan ",["Returning "]="Kembali ",["Avoiding "]="Menghindari ",
}
local DYNAMIC_PATTERNS_ID = {
    {pat="^QUICK BAR (%d+)$",rep="BILAH CEPAT %1"},
    {pat="^ALL (%d+)$",rep="SEMUA %1"},
    {pat="^READY (%d+)$",rep="SIAP %1"},
    {pat="^GROWING (%d+)$",rep="TUMBUH %1"},
    {pat="^IN BAG (%d+)$",rep="DI TAS %1"},
}

-- ---- PATTERNS VI (merged – FULL base + Beta extras) ----
local STATUS_ACTION_PATTERNS_VI = {
    {pat="^[Cc]arrying (.+) to safe zone$",rep="Đang mang %1 về vùng an toàn"},
    {pat="^[Cc]arrying (.+) to base$",rep="Đang mang %1 về căn cứ"},
    {pat="^[Cc]arrying (.+) to pen$",rep="Đang mang %1 về chuồng"},
    {pat="^[Cc]arrying (.+) home$",rep="Đang mang %1 về nhà"},
    {pat="^[Cc]arrying (.+)$",rep="Đang bê %1"},
    {pat="^[Bb]ringing (.+) home$",rep="Đang mang %1 về nhà"},
    {pat="^[Bb]ringing (.+)$",rep="Đang mang %1"},
    {pat="^[Dd]elivering (.+) to (.+)$",rep="Đang giao %1 tới %2"},
    {pat="^[Dd]elivering (.+) home$",rep="Đang giao %1 về nhà"},
    {pat="^[Dd]elivering (.+)$",rep="Đang giao %1"},
    {pat="^[Tt]aking (.+) from (.+)$",rep="Đang giật %1 từ %2"},
    {pat="^[Tt]aking (.+) home$",rep="Đang đem %1 về nhà"},
    {pat="^[Tt]aking (.+)$",rep="Đang lấy %1"},
    {pat="^[Ss]tealing (.+) from (.+)$",rep="Đang cướp %1 từ %2"},
    {pat="^[Ss]tealing (.+)$",rep="Đang cướp %1"},
    {pat="^[Gg]rabbing (.+)$",rep="Đang chộp lấy %1"},
    {pat="^[Pp]icking up (.+)$",rep="Đang nhặt %1"},
    {pat="^[Cc]ollecting (.+)$",rep="Đang thu thập %1"},
    {pat="^[Hh]olding (.+)$",rep="Đang giữ %1"},
    {pat="^[Cc]apturing (.+)$",rep="Đang bắt giữ %1"},
    {pat="^[Dd]ropping (.+) at (.+)$",rep="Đang thả %1 tại %2"},
    {pat="^[Dd]ropping (.+)$",rep="Đang thả %1"},
    {pat="^[Tt]weening to (.+)$",rep="Đang bay tới %1"},
    {pat="^[Tt]eleporting to (.+)$",rep="Đang dịch chuyển tới %1"},
    {pat="^[Ff]lying to (.+)$",rep="Đang bay tới %1"},
    {pat="^[Ww]alking to (.+)$",rep="Đang đi tới %1"},
    {pat="^[Rr]unning to (.+)$",rep="Đang chạy tới %1"},
    {pat="^[Gg]oing to (.+)$",rep="Đang đi tới %1"},
    {pat="^[Mm]oving to (.+)$",rep="Đang di chuyển tới %1"},
    {pat="^[Rr]eturning to (.+)$",rep="Đang quay về %1"},
    {pat="^[Hh]eading to (.+)$",rep="Đang hướng tới %1"},
    {pat="^[Pp]lacing (.+)$",rep="Đang đặt %1"},
    {pat="^[Hh]atching (.+)$",rep="Đang ấp %1"},
    {pat="^[Mm]utating (.+)$",rep="Đang đột biến %1"},
    {pat="^[Ss]elling (.+)$",rep="Đang bán %1"},
    {pat="^[Ff]using (.+)$",rep="Đang dung hợp %1"},
    {pat="^[Uu]pgrading (.+)$",rep="Đang nâng cấp %1"},
    {pat="^[Bb]uying (.+)$",rep="Đang mua %1"},
    {pat="^[Cc]laiming (.+)$",rep="Đang nhận %1"},
    {pat="^[Ee]quipping (.+)$",rep="Đang trang bị %1"},
    {pat="^[Ff]avoriting (.+)$",rep="Đang khóa bảo vệ %1"},
    {pat="^[Ee]jecting (.+)$",rep="Đang đẩy %1 ra"},
    {pat="^[Cc]atching (.+)$",rep="Đang bắt %1"},
    {pat="^[Cc]hasing (.+)$",rep="Đang đuổi theo %1"},
    {pat="^[Aa]ttacking (.+)$",rep="Đang tấn công %1"},
    {pat="^[Hh]itting (.+)$",rep="Đang đánh %1"},
    {pat="^[Kk]illing (.+)$",rep="Đang hạ %1"},
    {pat="^[Tt]rading (.+) for (.+)$",rep="Đang đổi %1 lấy %2"},
    {pat="^[Tt]rading in (.+)$",rep="Đang đổi %1"},
    {pat="^[Tt]rading (.+)$",rep="Đang giao dịch %1"},
    {pat="^[Cc]rafting (.+)$",rep="Đang chế tạo %1"},
    {pat="^[Rr]erolling (.+)$",rep="Đang đổi lại %1"},
    {pat="^[Aa]voiding (.+)$",rep="Đang né %1"},
    {pat="^[Ee]vading (.+)$",rep="Đang tránh %1"},
    {pat="^[Ff]arming (.+)$",rep="Đang cày %1"},
    {pat="^[Uu]sing (.+)$",rep="Đang dùng %1"},
    {pat="^[Jj]oining (.+)$",rep="Đang tham gia %1"},
    {pat="^[Hh]opping (.+)$",rep="Đang đổi %1"},
    {pat="^[Ww]aiting for (.+)$",rep="Đang chờ %1"},
    {pat="^[Ww]aiting in (.+)$",rep="Đang đợi ở %1"},
    {pat="^[Ww]aiting %((.+)%)$",rep="Đang chờ (%1)"},
    {pat="^[Ss]earching for (.+)$",rep="Đang tìm %1"},
    {pat="^[Ll]ooking for (.+)$",rep="Đang tìm %1"},
}
local FALLBACK_VERB_PREFIX_VI = {
    ["Carrying "]="Đang mang ",["Delivering "]="Đang giao ",["Stealing "]="Đang cướp ",
    ["Going "]="Đang đi ",["Tweening "]="Đang bay ",["Teleporting "]="Đang dịch chuyển ",
    ["Moving "]="Đang di chuyển ",["Walking "]="Đang đi bộ ",["Running "]="Đang chạy ",
    ["Flying "]="Đang bay ",["Placing "]="Đang đặt ",["Hatching "]="Đang ấp ",
    ["Mutating "]="Đang đột biến ",["Selling "]="Đang bán ",["Fusing "]="Đang dung hợp ",
    ["Catching "]="Đang bắt ",["Chasing "]="Đang đuổi theo ",["Waiting "]="Đang chờ ",
    ["Searching "]="Đang tìm ",["Claiming "]="Đang nhận ",["Upgrading "]="Đang nâng cấp ",
    ["Buying "]="Đang mua ",["Trading "]="Đang đổi ",["Crafting "]="Đang chế tạo ",
    ["Collecting "]="Đang thu thập ",["Holding "]="Đang giữ ",["Dropping "]="Đang thả ",
    ["Returning "]="Đang quay về ",["Avoiding "]="Đang né ",["Evading "]="Đang né ",
    ["Attacking "]="Đang đánh ",["Hitting "]="Đang đánh ",["Farming "]="Đang cày ",
}
local DYNAMIC_PATTERNS_VI = {
    {pat="^QUICK BAR (%d+)$",rep="THANH NHANH %1"},
    -- Thời gian "X ago" dạng viết tắt
    {pat="^(%d+)s ago$",rep="%1 giây trước"},
    {pat="^(%d+)m ago$",rep="%1 phút trước"},
    {pat="^(%d+)h ago$",rep="%1 giờ trước"},
    {pat="^(%d+)d ago$",rep="%1 ngày trước"},
    -- Thời gian "X ago" dạng đầy đủ
    {pat="^(%d+) seconds? ago$",rep="%1 giây trước"},
    {pat="^(%d+) minutes? ago$",rep="%1 phút trước"},
    {pat="^(%d+) hours? ago$",rep="%1 giờ trước"},
    {pat="^(%d+) days? ago$",rep="%1 ngày trước"},
    {pat="^just now$",rep="vừa xong"},
    -- Countdown timer "Xm Xs" hoặc "Xh Xm"
    {pat="^(%d+)m (%d+)s$",rep="%1 phút %2 giây"},
    {pat="^(%d+)h (%d+)m$",rep="%1 giờ %2 phút"},
    {pat="^(%d+)h (%d+)m (%d+)s$",rep="%1 giờ %2 phút %3 giây"},
    -- Steal Panel buttons động
    {pat="^Auto Steal: (ON)$",rep="Tự Động Cướp: BẬT"},
    {pat="^Auto Steal: (OFF)$",rep="Tự Động Cướp: TẮT"},
    {pat="^Halloween: (ON)$",rep="Halloween: BẬT"},
    {pat="^Halloween: (OFF)$",rep="Halloween: TẮT"},
    {pat="^Eggs: (.+)$",rep="Trứng: %1"},
    -- Generic ON/OFF suffix (fallback)
    {pat="^(.+): ON$",rep="%1: BẬT"},
    {pat="^(.+): OFF$",rep="%1: TẮT"},
    {pat="Venyx(.-)(%d+) hours? ago",rep="TLN CHEAT%1%2 giờ trước"},
    {pat="Venyx(.-)(%d+) minutes? ago",rep="TLN CHEAT%1%2 phút trước"},
    {pat="Venyx(.-)(%d+) days? ago",rep="TLN CHEAT%1%2 ngày trước"},
    {pat="^ALL (%d+)$",rep="TẤT CẢ %1"},
    {pat="^READY (%d+)$",rep="SẴN SÀNG %1"},
    {pat="^GROWING (%d+)$",rep="ĐANG LỚN %1"},
    {pat="^IN BAG (%d+)$",rep="TRONG TÚI %1"},
    {pat="Pen (%d+/%d+) · (%d+) egg%(s%) ready to place",rep="Chuồng %1 · %2 trứng sẵn sàng đặt"},
    {pat="(%d+) egg%(s%) can be mutated",rep="%1 trứng có thể đột biến"},
    {pat="(%d+) pet%(s%) match",rep="%1 pet khớp bộ lọc"},
    {pat="(%d+) egg%(s%) match",rep="%1 trứng khớp bộ lọc"},
    {pat="(%d+) lab egg%(s%) match",rep="%1 trứng Lab khớp bộ lọc"},
    {pat="^(%d+) pets$",rep="%1 thú cưng"},
    {pat="(%d+ / %d+) players · (.+)",rep="%1 người chơi · %2"},
    {pat="Experimental Pets · needs (.-) · pity (%d+/%d+) · rerolls (%d+) · (.+)",rep="Pet Thí Nghiệm · cần %1 · bảo hiểm %2 · lượt đổi %3 · %4"},
    {pat="Biohazard Pets · needs (.-) · pity (%d+/%d+) · rerolls (%d+) · (.+)",rep="Pet Sinh Học · cần %1 · bảo hiểm %2 · lượt đổi %3 · %4"},
    {pat="Unstable DNA · needs (.-) · pity (%d+/%d+) · rerolls (%d+) · (.+)",rep="DNA Bất Ổn · cần %1 · bảo hiểm %2 · lượt đổi %3 · %4"},
    {pat="^Mythic · 1 in ([%d%.]+)$",rep="Thần Thoại · 1 trên %1"},
    {pat="^Cosmic · 1 in ([%d%.]+)$",rep="Vũ Trụ · 1 trên %1"},
    {pat="^Secret · 1 in ([%d%.]+)$",rep="Bí Ẩn · 1 trên %1"},
    {pat="^Divine · 1 in ([%d%.]+)$",rep="Thánh Thần · 1 trên %1"},
    {pat="^Eternal · 1 in ([%d%.]+)$",rep="Vĩnh Cửu · 1 trên %1"},
}

-- ==================== 4. HÀM DỊCH ====================
local function translateStatusAction(cleanEn)
    if not cleanEn or cleanEn == "" then
        if currentLanguage == "ID" then return "Menganggur" end
        return "Đang rảnh"
    end
    if currentLanguage == "EN" then
        if cleanEn == "Đang rảnh" or cleanEn == "Menganggur" then return "Idle" end
        return cleanEn
    end
    local trimmed = (cleanEn:match("^%s*(.-)%s*$") or cleanEn):gsub("%s+", " ")
    -- Indonesian branch
    if currentLanguage == "ID" then
        if trimmed:lower() == "idle" or trimmed == "Menganggur" then return "Menganggur" end
        local cacheKey = "STATUS_ID|" .. trimmed
        if FastCache[cacheKey] then return FastCache[cacheKey] end
        if EXACT_MATCH_ID[trimmed] then FastCache[cacheKey] = EXACT_MATCH_ID[trimmed]; return EXACT_MATCH_ID[trimmed] end
        for _, item in ipairs(STATUS_ACTION_PATTERNS_ID) do
            if trimmed:find(item.pat) then
                local out = trimmed:gsub(item.pat, item.rep)
                FastCache[cacheKey] = out; return out
            end
        end
        local result = trimmed
        for engPrefix, idPrefix in pairs(FALLBACK_VERB_PREFIX_ID) do
            if result:sub(1, #engPrefix):lower() == engPrefix:lower() then
                result = idPrefix .. result:sub(#engPrefix + 1); break
            end
        end
        FastCache[cacheKey] = result; return result
    end
    -- Vietnamese branch
    if trimmed:lower() == "idle" or trimmed == "Đang rảnh" then return "Đang rảnh" end
    local cacheKey = "STATUS_VI|" .. trimmed
    if FastCache[cacheKey] then return FastCache[cacheKey] end
    if EXACT_MATCH_VI[trimmed] then FastCache[cacheKey] = EXACT_MATCH_VI[trimmed]; return EXACT_MATCH_VI[trimmed] end
    for _, item in ipairs(STATUS_ACTION_PATTERNS_VI) do
        if trimmed:find(item.pat) then
            local out = trimmed:gsub(item.pat, item.rep)
            FastCache[cacheKey] = out; return out
        end
    end
    local result = trimmed
    for engPrefix, viPrefix in pairs(FALLBACK_VERB_PREFIX_VI) do
        if result:sub(1, #engPrefix):lower() == engPrefix:lower() then
            result = viPrefix .. result:sub(#engPrefix + 1); break
        end
    end
    result = result:gsub(" home$", " về nhà"):gsub(" to safe zone$", " về vùng an toàn"):gsub(" to base$", " về căn cứ")
    FastCache[cacheKey] = result; return result
end

local function translateTLNText(raw)
    if not raw or raw == "" then return raw end
    local cacheKey = currentLanguage .. "|" .. raw
    if FastCache[cacheKey] then return FastCache[cacheKey] end
    if raw:find("Venyx SAE") then raw = raw:gsub("Venyx SAE", "TLN SAE")
    elseif raw == "VENYX" then raw = NEW_TITLE end
    if currentLanguage == "EN" then FastCache[cacheKey] = raw; return raw end
    local normalized = (raw:match("^%s*(.-)%s*$") or raw):gsub("%s+", " ")
    -- Indonesian branch
    if currentLanguage == "ID" then
        if EXACT_MATCH_ID[normalized] then
            local out = EXACT_MATCH_ID[normalized]; FastCache[cacheKey] = out; return out
        end
        local result = normalized
        for _, item in ipairs(DYNAMIC_PATTERNS_ID) do
            if result:find(item.pat) then
                result = result:gsub(item.pat, item.rep); FastCache[cacheKey] = result; return result
            end
        end
        for _, item in ipairs(STATUS_ACTION_PATTERNS_ID) do
            if result:find(item.pat) then
                result = result:gsub(item.pat, item.rep); FastCache[cacheKey] = result; return result
            end
        end
        FastCache[cacheKey] = raw; return raw
    end
    -- Vietnamese branch
    if EXACT_MATCH_VI[normalized] then
        local out = EXACT_MATCH_VI[normalized]; FastCache[cacheKey] = out; return out
    end
    -- Prefix symbol detection (e.g. "🔥 Auto steal")
    local prefix, wordPart = normalized:match("^([^%w%s]+%s*)(.+)$")
    if prefix and wordPart and EXACT_MATCH_VI[wordPart] then
        local out = prefix .. EXACT_MATCH_VI[wordPart]; FastCache[cacheKey] = out; return out
    end
    local result = normalized
    for _, item in ipairs(DYNAMIC_PATTERNS_VI) do
        if result:find(item.pat) then
            result = result:gsub(item.pat, item.rep); FastCache[cacheKey] = result; return result
        end
    end
    for _, item in ipairs(STATUS_ACTION_PATTERNS_VI) do
        if result:find(item.pat) then
            result = result:gsub(item.pat, item.rep); FastCache[cacheKey] = result; return result
        end
    end
    FastCache[cacheKey] = raw; return raw
end

local function applyElementTranslation(inst)
    if not (inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox")) then return end
    if inst:GetAttribute("__IslandDone") or inst:GetAttribute("__FpsHooked") or inst:GetAttribute("__HiddenVxLogo") or inst.Name == "IslandExpandHint" or inst:FindFirstAncestor("ChilliV5_ExpandedIsland") then return end
    if inst:GetAttribute("__IsTranslating") then return end
    if inst:IsA("TextBox") then
        local origPh = inst:GetAttribute("OrigPlaceholder")
        if not origPh and inst.PlaceholderText ~= "" then origPh = inst.PlaceholderText; inst:SetAttribute("OrigPlaceholder", origPh) end
        if origPh then inst.PlaceholderText = translateTLNText(origPh) end
        return
    end
    local rawText = inst.Text
    if isFpsCounterText(rawText) then hookFakeFpsCounter(inst); return end
    local original = inst:GetAttribute("OrigRawText")
    if not original then original = rawText; inst:SetAttribute("OrigRawText", original) end
    local mapped = translateTLNText(original)
    if inst.Text ~= mapped then
        inst:SetAttribute("__IsTranslating", true)
        inst:SetAttribute("__LastTranslated", mapped)
        pcall(function() inst.Text = mapped end)
        task.defer(function() inst:SetAttribute("__IsTranslating", false) end)
    end
end

local function hookTextForTranslation(inst)
    if not (inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox")) then return end
    if inst:GetAttribute("__IslandDone") or inst:GetAttribute("__HiddenVxLogo") or inst.Name == "IslandExpandHint" or inst:FindFirstAncestor("ChilliV5_ExpandedIsland") then return end
    if not inst:IsA("TextBox") and isFpsCounterText(inst.Text) then hookFakeFpsCounter(inst); return end
    applyElementTranslation(inst)
    if inst:GetAttribute("__TransHooked") then return end
    inst:SetAttribute("__TransHooked", true)
    table.insert(TrackedTexts, inst)
    inst:GetPropertyChangedSignal("Text"):Connect(function()
        if inst:GetAttribute("__IsTranslating") or inst:GetAttribute("__IslandDone") or inst:GetAttribute("__HiddenVxLogo") then return end
        if isFpsCounterText(inst.Text) then hookFakeFpsCounter(inst); return end
        if inst.Text ~= inst:GetAttribute("__LastTranslated") then
            inst:SetAttribute("OrigRawText", inst.Text); applyElementTranslation(inst)
        end
    end)
end

local function refreshAllTranslations()
    for i = #TrackedTexts, 1, -1 do
        local el = TrackedTexts[i]
        if el and el.Parent then applyElementTranslation(el)
        else table.remove(TrackedTexts, i) end
    end
    if GlobalRefreshIslandStatus then GlobalRefreshIslandStatus() end
end

-- ==================== 5. DYNAMIC ISLAND – 3 NÚT (VI | EN | ID) ====================
local function setupDynamicIslandFromStatus(statusLbl, tlnGui)
    local pill = statusLbl.Parent
    if not (pill and pill:IsA("GuiObject")) then return end
    if statusLbl:GetAttribute("__IslandDone") then return end
    statusLbl:SetAttribute("__IslandDone", true)
    GlobalRefreshIslandStatus = function() end

    statusLbl.Text = ""
    statusLbl.TextTransparency = 1
    statusLbl.Size = UDim2.new(0, 0, 0, 0)
    statusLbl.AutomaticSize = Enum.AutomaticSize.None
    statusLbl.Active = false
    statusLbl:GetPropertyChangedSignal("Text"):Connect(function()
        if statusLbl.Text ~= "" then
            statusLbl:SetAttribute("__Updating", true)
            statusLbl.Text = ""
            task.defer(function() statusLbl:SetAttribute("__Updating", false) end)
        end
    end)

    for _, child in ipairs(pill:GetChildren()) do
        if child:IsA("UIGradient") then child:Destroy() end
    end
    local badHitbox = pill:FindFirstChild("IslandClickHitbox")
    if badHitbox then badHitbox:Destroy() end
    local oldExpandHint = pill:FindFirstChild("IslandExpandHint")
    if oldExpandHint then oldExpandHint:Destroy() end
    local oldExp = tlnGui:FindFirstChild("ChilliV5_ExpandedIsland")
    if oldExp then oldExp:Destroy() end

    -- Ẩn pill gốc hoàn toàn - không chiến với VenyxHub nữa
    pill.BackgroundTransparency = 1
    pill.Size = UDim2.new(0, 0, 0, 0)
    pill.Active = false
    pill:GetPropertyChangedSignal("BackgroundTransparency"):Connect(function()
        if pill.BackgroundTransparency ~= 1 then pill.BackgroundTransparency = 1 end
    end)

    -- Tạo frame riêng hoàn toàn độc lập, không bị VenyxHub can thiệp
    local langBar = tlnGui:FindFirstChild("TLNLangBar")
    if langBar then langBar:Destroy() end
    langBar = Instance.new("Frame")
    langBar.Name       = "TLNLangBar"
    langBar.Size       = UDim2.new(0, 330, 0, 30)
    langBar.Position   = UDim2.new(0.5, 0, 0, 8)
    langBar.AnchorPoint = Vector2.new(0.5, 0)
    langBar.BackgroundColor3 = ISLAND_BLACK_BG
    langBar.BackgroundTransparency = 0
    langBar.BorderSizePixel = 0
    langBar.ZIndex     = 9999
    langBar.ClipsDescendants = false
    langBar.Active     = true
    langBar.Parent     = tlnGui

    local lbCorner = Instance.new("UICorner")
    lbCorner.CornerRadius = UDim.new(1, 0); lbCorner.Parent = langBar

    local lbStroke = Instance.new("UIStroke")
    lbStroke.Name = "IslandStroke"; lbStroke.Thickness = 1.6
    lbStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    lbStroke.Color = Color3.fromRGB(255, 255, 255); lbStroke.Parent = langBar
    local strokeGrad = Instance.new("UIGradient")
    strokeGrad.Color = COLOR_SEQ_RAINBOW; strokeGrad.Parent = lbStroke
    table.insert(ActiveGradients, strokeGrad)

    -- alias để code bên dưới dùng chung
    local pill = langBar

    local LangSlider = Instance.new("Frame")
    LangSlider.Name = "LangSlider"
    LangSlider.Size = UDim2.new(1/3, -4, 1, -4)
    LangSlider.Position = UDim2.new(0, 2, 0, 2)
    LangSlider.BackgroundColor3 = Color3.fromRGB(95, 110, 235)
    LangSlider.BorderSizePixel = 0; LangSlider.ZIndex = 10000; LangSlider.Parent = pill
    local SliderCorner = Instance.new("UICorner")
    SliderCorner.CornerRadius = UDim.new(1, 0); SliderCorner.Parent = LangSlider

    local BtnVI = Instance.new("TextButton")
    BtnVI.Name = "BtnVI"; BtnVI.Size = UDim2.new(1/3, 0, 1, 0); BtnVI.Position = UDim2.new(0, 0, 0, 0)
    BtnVI.BackgroundTransparency = 1; BtnVI.Text = "🇻🇳 Việt"
    BtnVI.Font = Enum.Font.GothamBold; BtnVI.TextSize = 10.5
    BtnVI.TextColor3 = Color3.fromRGB(255, 255, 255); BtnVI.ZIndex = 10001; BtnVI.Parent = pill

    local BtnEN = Instance.new("TextButton")
    BtnEN.Name = "BtnEN"; BtnEN.Size = UDim2.new(1/3, 0, 1, 0); BtnEN.Position = UDim2.new(1/3, 0, 0, 0)
    BtnEN.BackgroundTransparency = 1; BtnEN.Text = "🌐 English"
    BtnEN.Font = Enum.Font.GothamBold; BtnEN.TextSize = 10.5
    BtnEN.TextColor3 = Color3.fromRGB(150, 165, 190); BtnEN.ZIndex = 10001; BtnEN.Parent = pill

    local BtnID = Instance.new("TextButton")
    BtnID.Name = "BtnID"; BtnID.Size = UDim2.new(1/3, 0, 1, 0); BtnID.Position = UDim2.new(2/3, 0, 0, 0)
    BtnID.BackgroundTransparency = 1; BtnID.Text = "🇮🇩 Indo"
    BtnID.Font = Enum.Font.GothamBold; BtnID.TextSize = 10.5
    BtnID.TextColor3 = Color3.fromRGB(150, 165, 190); BtnID.ZIndex = 10001; BtnID.Parent = pill

    local LANG_POSITIONS = {
        VI = UDim2.new(0, 2, 0, 2),
        EN = UDim2.new(1/3, 2, 0, 2),
        ID = UDim2.new(2/3, 2, 0, 2),
    }
    local DIM = Color3.fromRGB(150, 165, 190)
    local LIT = Color3.fromRGB(255, 255, 255)

    local function setLanguage(lang)
        if currentLanguage == lang then return end
        currentLanguage = lang
        TweenService:Create(LangSlider, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = LANG_POSITIONS[lang]}):Play()
        BtnVI.TextColor3 = (lang == "VI") and LIT or DIM
        BtnEN.TextColor3 = (lang == "EN") and LIT or DIM
        BtnID.TextColor3 = (lang == "ID") and LIT or DIM
        refreshAllTranslations()
    end

    BtnVI.MouseButton1Click:Connect(function() setLanguage("VI") end)
    BtnEN.MouseButton1Click:Connect(function() setLanguage("EN") end)
    BtnID.MouseButton1Click:Connect(function() setLanguage("ID") end)

    local function attachDrag(triggerObj, moveFrame)
        if triggerObj:GetAttribute("__DragBound") then return end
        triggerObj:SetAttribute("__DragBound", true)
        local dragging, dragStart, startPos = false, nil, nil
        triggerObj.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true; dragStart = input.Position; startPos = moveFrame.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then dragging = false end
                end)
            end
        end)
        triggerObj.InputChanged:Connect(function(input)
            if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragging then
                local delta = input.Position - dragStart
                local cam = workspace.CurrentCamera
                local screenW = cam and cam.ViewportSize.X or 800
                local screenH = cam and cam.ViewportSize.Y or 600
                -- pill rộng 300px, neo tại 50% → giới hạn offset để không ra ngoài màn hình
                local halfPill = 169  -- 330/2 + 4px padding
                local maxX     = math.floor(screenW / 2) - halfPill
                local newX     = math.clamp(startPos.X.Offset + delta.X, -maxX, maxX)
                local newY     = math.clamp(startPos.Y.Offset + delta.Y, 4, screenH - 40)
                moveFrame.Position = UDim2.new(startPos.X.Scale, newX, startPos.Y.Scale, newY)
            end
        end)
    end
    attachDrag(pill, pill)
end

-- ==================== 6. LOGO TRÒN ====================
local function setupUnclippedCircularLogo(targetObj)
    local topPanel = targetObj
    while topPanel.Parent and topPanel.Parent:IsA("GuiObject") and not topPanel.Parent:IsA("ScreenGui") do
        topPanel = topPanel.Parent
    end
    if topPanel:GetAttribute("__FloatingLogoV5Perfect") then return end
    local sz = topPanel.AbsoluteSize; local pos = topPanel.AbsolutePosition
    if sz.X > 105 or sz.Y > 105 or sz.X < 28 or math.abs(sz.X - sz.Y) > 25 or pos.X > 350 then return end
    topPanel:SetAttribute("__FloatingLogoV5Perfect", true)
    local container = topPanel
    for _, child in ipairs(container:GetDescendants()) do
        if child:IsA("UIPadding") or child:IsA("UIAspectRatioConstraint") or child:IsA("UISizeConstraint") then
            if child.Name ~= "PerfectCircleAspect" then pcall(function() child:Destroy() end) end
        end
        if (child:IsA("ImageLabel") or child:IsA("ImageButton")) and child.Name ~= "ChilliV5CoverLogo" then
            child.ImageTransparency = 1; child.BackgroundTransparency = 1
        elseif child:IsA("TextLabel") or child:IsA("TextButton") then
            child:SetAttribute("__HiddenVxLogo", true); child.TextTransparency = 1; child.BackgroundTransparency = 1
        end
    end
    if container:IsA("ImageLabel") or container:IsA("ImageButton") then container.ImageTransparency = 1
    elseif container:IsA("TextLabel") or container:IsA("TextButton") then
        container:SetAttribute("__HiddenVxLogo", true); container.TextTransparency = 1
    end
    container.Size = UDim2.new(0, 60, 0, 60)
    container.BackgroundColor3 = LOGO_BG_COLOR
    container.BackgroundTransparency = 0; container.BorderSizePixel = 0; container.ClipsDescendants = true
    local aspect = container:FindFirstChild("PerfectCircleAspect") or Instance.new("UIAspectRatioConstraint")
    aspect.Name = "PerfectCircleAspect"; aspect.AspectRatio = 1; aspect.Parent = container
    local cCorner = container:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
    cCorner.CornerRadius = UDim.new(1, 0); cCorner.Parent = container
    if not container:GetAttribute("__SizeLocked") then
        container:SetAttribute("__SizeLocked", true)
        container:GetPropertyChangedSignal("Size"):Connect(function()
            if container.Size ~= UDim2.new(0, 60, 0, 60) then container.Size = UDim2.new(0, 60, 0, 60) end
        end)
    end
    local stroke = container:FindFirstChild("RainbowBorder") or Instance.new("UIStroke")
    stroke.Name = "RainbowBorder"; stroke.Thickness = 2.5
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Color = Color3.fromRGB(255, 255, 255); stroke.Parent = container
    local strokeGrad = stroke:FindFirstChildOfClass("UIGradient") or Instance.new("UIGradient")
    strokeGrad.Color = COLOR_SEQ_RAINBOW; strokeGrad.Parent = stroke
    table.insert(ActiveGradients, strokeGrad)
    local coverLogo = container:FindFirstChild("ChilliV5CoverLogo") or Instance.new("ImageLabel")
    coverLogo.Name = "ChilliV5CoverLogo"; coverLogo.Size = UDim2.new(1, 0, 1, 0)
    coverLogo.Position = UDim2.new(0.5, 0, 0.5, 0); coverLogo.AnchorPoint = Vector2.new(0.5, 0.5)
    coverLogo.BackgroundTransparency = 1; coverLogo.Image = CHILLI_LOGO_ID
    coverLogo.ImageTransparency = 0; coverLogo.ScaleType = Enum.ScaleType.Fit
    coverLogo.Active = false; coverLogo.ZIndex = container.ZIndex + 5; coverLogo.Parent = container
    local logoCorner = coverLogo:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
    logoCorner.CornerRadius = UDim.new(1, 0); logoCorner.Parent = coverLogo
end

local function patchHeaderLogoLeftOfTitle(headerContainer, titleLbl)
    if not headerContainer or not titleLbl then return end
    local headerY = titleLbl.AbsolutePosition.Y; local titleX = titleLbl.AbsolutePosition.X
    for _, item in ipairs(headerContainer:GetDescendants()) do
        if item ~= titleLbl and item:IsA("GuiObject") and item.Name ~= "ChilliHeaderLogo" then
            local pos = item.AbsolutePosition; local sz = item.AbsoluteSize
            if math.abs(pos.Y - headerY) < 35 and pos.X < titleX and sz.X >= 10 and sz.X <= 45 then
                if item:IsA("ImageLabel") or item:IsA("ImageButton") then
                    item.Image = CHILLI_LOGO_ID; item.ImageTransparency = 0
                    item.BackgroundTransparency = 1; item.ScaleType = Enum.ScaleType.Fit
                elseif item:IsA("TextLabel") or item:IsA("TextButton") then
                    item:SetAttribute("__HiddenVxLogo", true); item.TextTransparency = 1
                    local holder = item.Parent
                    if holder and not holder:FindFirstChild("ChilliHeaderLogo") then
                        local hLogo = Instance.new("ImageLabel")
                        hLogo.Name = "ChilliHeaderLogo"; hLogo.Size = UDim2.new(0, 24, 0, 24)
                        hLogo.Position = UDim2.new(0.5, 0, 0.5, 0); hLogo.AnchorPoint = Vector2.new(0.5, 0.5)
                        hLogo.BackgroundTransparency = 1; hLogo.Image = CHILLI_LOGO_ID
                        hLogo.ScaleType = Enum.ScaleType.Fit; hLogo.ZIndex = item.ZIndex + 2; hLogo.Parent = holder
                    end
                end
            end
        end
    end
end

-- ==================== 7. MAIN SCAN ====================
local function tryPatchTLN()
    for _, root in ipairs(roots) do
        if root then
            for _, gui in ipairs(root:GetChildren()) do
                if gui:IsA("ScreenGui") and gui.Name ~= "RobloxGui" and gui.Name ~= "TopBarApp" then
                    -- Gộp 2 pass thành 1 để tránh GetDescendants() 2 lần
                    local titleLbl = nil
                    local allDesc = gui:GetDescendants()
                    for _, d in ipairs(allDesc) do
                        if d:IsA("TextLabel") or d:IsA("TextButton") then
                            if isFpsCounterText(d.Text) then
                                hookFakeFpsCounter(d)
                            end
                            if not titleLbl and not d:FindFirstAncestorOfClass("ScrollingFrame") then
                                local t = d.Text
                                if t == "VENYX" or t == NEW_TITLE then titleLbl = d end
                            end
                        end
                    end
                    if titleLbl then
                        if titleLbl.Text ~= NEW_TITLE then
                            titleLbl.Text = NEW_TITLE; titleLbl.AutomaticSize = Enum.AutomaticSize.X
                        end
                        local mainWindow = nil; local curr = titleLbl
                        while curr.Parent and curr.Parent ~= gui do
                            curr = curr.Parent
                            if curr:IsA("GuiObject") and curr.AbsoluteSize.X >= 350 and curr.AbsoluteSize.Y >= 220 then
                                mainWindow = curr
                            end
                        end
                        local headerY = titleLbl.AbsolutePosition.Y
                        if mainWindow then patchHeaderLogoLeftOfTitle(mainWindow, titleLbl) end
                        if not gui:GetAttribute("__TextListenerAttached") then
                            gui:SetAttribute("__TextListenerAttached", true)
                            gui.DescendantAdded:Connect(function(newDesc)
                                if newDesc:IsA("TextLabel") or newDesc:IsA("TextButton") or newDesc:IsA("TextBox") then
                                    task.defer(function() hookTextForTranslation(newDesc) end)
                                end
                            end)
                        end
                        for _, topChild in ipairs(gui:GetChildren()) do
                            if topChild:IsA("GuiObject") and topChild ~= mainWindow
                            and topChild.Name ~= "ChilliV5_ExpandedIsland"
                            and not topChild:FindFirstChild("IslandExpandHint") then
                                setupUnclippedCircularLogo(topChild)
                            end
                        end
                        for _, desc in ipairs(allDesc) do
                            if desc:IsA("TextLabel") or desc:IsA("TextButton") or desc:IsA("TextBox") then
                                local txt = desc.Text or ""; local origTxt = desc:GetAttribute("OrigRawText") or ""
                                local isAlreadyMovedIdle = desc:GetAttribute("__IslandDone")
                                local isStatusKeyword = txt:lower():find("idle") or origTxt:lower():find("idle") or txt == "Đang rảnh"
                                local isHeaderIdle = (not gui:GetAttribute("__IslandLocked"))
                                    and (not desc:FindFirstAncestorOfClass("ScrollingFrame"))
                                    and desc.Parent
                                    and (not titleLbl:IsDescendantOf(desc.Parent))
                                    and math.abs(desc.AbsolutePosition.Y - headerY) < 35
                                    and desc.AbsolutePosition.X > titleLbl.AbsolutePosition.X + 60
                                    and isStatusKeyword
                                if isHeaderIdle or isAlreadyMovedIdle then
                                    gui:SetAttribute("__IslandLocked", true)
                                    setupDynamicIslandFromStatus(desc, gui)
                                else
                                    hookTextForTranslation(desc)
                                end
                            elseif (desc:IsA("ImageLabel") or desc:IsA("ImageButton"))
                            and desc.Name ~= "ChilliV5CoverLogo" and desc.Name ~= "ChilliHeaderLogo"
                            and desc.Name ~= "InnerChilliLogo" then
                                if not desc:FindFirstAncestorOfClass("ScrollingFrame") then
                                    if mainWindow and not desc:IsDescendantOf(mainWindow) then
                                        setupUnclippedCircularLogo(desc)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

-- tryPatchTLN chạy NGAY - không cần chờ hub API
pcall(tryPatchTLN)

-- Root watcher: bắt GUI mới thêm vào bất cứ lúc nào (debounce để không scan 2 lần)
task.spawn(function()
    for _, root in ipairs(roots) do
        if root then
            local _scanPending = false
            root.ChildAdded:Connect(function()
                if _scanPending then return end
                _scanPending = true
                task.wait(0.5)
                pcall(tryPatchTLN)
                _scanPending = false
            end)
        end
    end
end)

-- Rapid scan 30s rồi keepalive mãi (giảm tần suất để bớt giật)
task.spawn(function()
    task.desync()  -- chạy off main thread, không block render
    for _ = 1, 30 do
        task.wait(1); pcall(tryPatchTLN)
    end
    while true do
        task.wait(7); pcall(tryPatchTLN)
    end
end)

-- ==================== THÊM CHỨC NĂNG TẠI ĐÂY ====================
-- Dùng onHubReady để đảm bảo hub đã load xong trước khi thêm
-- Ví dụ:
-- onHubReady(function(Hub)
--     if not Hub then return end
--     local tab = Hub:MakeTab({ Name = "Custom" })
--     local sec = tab:AddSection({ Name = "My Features" })
--     sec:AddToggle({
--         Name    = "Tên chức năng",
--         Default = false,
--         Callback = function(v)
--             -- code ở đây
--         end
--     })
-- end)

-- ==================== 8. TELEGRAM + WHAT'S NEW + CHILLI HUB PATCH ====================
task.spawn(function()
    if setclipboard then
        local origClipboard = setclipboard
        setclipboard = function(text)
            if type(text) == "string" and text:find("discord%.gg") then
                origClipboard(TELEGRAM_LINK)
            else
                origClipboard(text)
            end
        end
    end

    local patched = {}

    local function patchGui(gui)
        if not gui:IsA("ScreenGui") then return end
        local function scanDesc(desc)
            -- Ẩn WHAT'S NEW panels
            if desc:IsA("Frame") or desc:IsA("ScrollingFrame") then
                local name = desc.Name:lower()
                if name:find("whatsnew") or name:find("whats_new") or name:find("changelog") or name:find("news") then
                    desc.Visible = false; return
                end
                for _, child in ipairs(desc:GetChildren()) do
                    if (child:IsA("TextLabel") or child:IsA("TextButton")) then
                        local t = child.Text or ""
                        if t == "WHAT'S NEW" or t == "CÓ GÌ MỚI" or t == "APA YANG BARU" then
                            desc.Visible = false; break
                        end
                    end
                end
            end
            -- "Chilli Hub" → "TLN CHEAT"
            if (desc:IsA("TextButton") or desc:IsA("TextLabel")) and not patched[desc] then
                local t = desc.Text or ""
                if t == "Chilli Hub" or t == "Chilli hub" or t == "CHILLI HUB" then
                    patched[desc] = true
                    desc.Text = "TLN CHEAT"
                    desc:GetPropertyChangedSignal("Text"):Connect(function()
                        if desc.Text ~= "TLN CHEAT" then desc.Text = "TLN CHEAT" end
                    end)
                end
            end
            -- Copy Invite → Telegram
            if desc:IsA("TextButton") and not patched[desc] then
                local t = (desc.Text or ""):lower()
                if t:find("copy invite") or t:find("chép link") then
                    patched[desc] = true
                    desc.MouseButton1Click:Connect(function()
                        pcall(function() if setclipboard then setclipboard(TELEGRAM_LINK) end end)
                    end)
                end
            end
        end
        for _, desc in ipairs(gui:GetDescendants()) do pcall(scanDesc, desc) end
        gui.DescendantAdded:Connect(function(newDesc)
            task.defer(function() pcall(scanDesc, newDesc) end)
        end)
    end

    for i = 1, 60 do
        task.wait(0.5)
        for _, root in ipairs(roots) do
            if root then
                for _, gui in ipairs(root:GetChildren()) do
                    pcall(patchGui, gui)
                end
            end
        end
    end
end)
