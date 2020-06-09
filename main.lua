require "TSLib"
local ts = require("ts")
local json = ts.json
local run = require("run")
local userLevelSign = {xin = "xin.png", xin2 = "xin.png" , tie = "tie.png", tie2 = "tie.png" , zuan = "zuan.png", zhi = "zhi.png"}
local userNameTable = {}
local userNameExist = {}
-- 初始化日志
run.initLog()
liveRetryTimes = 0
--iOS 需要下载 v1.4.0 及其以上版本 ts.so，Android 需要下载 v1.1.1 及其以上版本ts.so，否则无法调用成功
-- local code,access_token = getAccessToken("DgTWidEgIA0Oy84asXqyh8sU","Vg3wtjblwf7pNLl2TC5CSK9eQ7jTbwrx")

function getNameByOcr(userLevel)
	-- 找到第一个白色字的位置
	local WhiteFontY = y
	local WhiteFontX = 450
	local NoWhiteFontCount = 0
	local WhiteFontCount = 0
	
	local deepWhiteFontY = y
	local deepWhiteFontX = 450
	local deepNoWhiteFontCount = 0
	local deepWhiteFontCount = 0
	while true do
		if isColor(WhiteFontX,WhiteFontY,0xffffff, 95) then
			WhiteFontX = WhiteFontX - 1
			WhiteFontY = y
			WhiteFontCount = WhiteFontCount + 1
			NoWhiteFontCount = 0
		else
			WhiteFontY = WhiteFontY + 1
		end
		
		-- 一列结束的判断标志
		if y + 24 < WhiteFontY then
			NoWhiteFontCount = NoWhiteFontCount + 1
			WhiteFontX = WhiteFontX - 1
			WhiteFontY = y
		end
		
		-- 判断没有白字的标志，前提是要遇到白字
		if NoWhiteFontCount >= 6 and WhiteFontCount >= 3 then
			-- 防止某些特殊符号，例如逗号的情况
			deepWhiteFontX = WhiteFontX 
			while true do
				if isColor(deepWhiteFontX,deepWhiteFontY,0xffffff, 95) then
					-- 发现还有白色字体
					WhiteFontX = deepWhiteFontX
					WhiteFontY = y
					NoWhiteFontCount = 0
					WhiteFontCount = 0
					break
				else
					deepWhiteFontY = deepWhiteFontY + 1
				end
				
				-- 一列结束的判断标志
				if y + 24 < deepWhiteFontY then
					deepNoWhiteFontCount = deepNoWhiteFontCount + 1
					deepWhiteFontX = deepWhiteFontX - 1
					deepWhiteFontY = y
				end
				
				-- 再次确定没有白色字
				if deepNoWhiteFontCount == 25 then
					break
				end
			end
			-- 检查double check 情况
			if NoWhiteFontCount >= 6 and WhiteFontCount >= 3 then
				break
			end
		end
		
		-- 异常情况
		if WhiteFontX <= 175 then
			break
		end
	end
	
	--toast("end")
	-- 设置图片保存路径
	local pic_name = userPath() .. "/res/tmp.jpg"
	-- 截取识别区域
	snapshot(userPath() .. "/res/origin.jpg",0,0, 749,1333)
	local vip88 = 2
	if isColor(136,y,0x6c5d4b) then
		vip88 = 1
		snapshot(pic_name, 170,y-3,WhiteFontX,y+27)
	else
		snapshot(pic_name, 128,y-3,WhiteFontX,y+27)
	end
	keepScreen(false)
	-- 请求百度 AI 进行文字识别
	local code, body = baiduAI("24.70cdbd75f782c8a8531ca0334aa38a8b.2592000.1572763461.282335-17397335",pic_name)
	-- 判断结果
	if code then
		nLog("baidu res:"..body)
		userNameTable = json.decode(body)
		if userNameTable.words_result_num == 1 then
			-- 识别成功
			checkUserName(userNameTable.words_result[1].words, userLevel, vip88)
		end
	end
end

-- 二次检查白色字体s
function doubleCheckWhiteFont()
end

function checkUserName(userName, userLevel, vip88)
	if userNameExist[userName] == 1 then
		liveRetryTimes = liveRetryTimes + 1
		return
	end
	userNameExist[userName] = 1
	writePasteboard(userName)
	openRes = openWangwang()
	if openRes == false then
		return
	end
	for var = 1,15 do
		keyDown("DeleteOrBackspace")       --删除输入框中的文字（假设输入框中已存在文字）
	end
	mSleep(500)
	ring = readPasteboard()
	mSleep(500)
	inputText(ring)
	mSleep(500)
	keyDown("ReturnOrEnter")
	keyUp("ReturnOrEnter")
	mSleep(2000)
	-- 判断帐号是否有效 3754.png
	if(isColor(323,86,0x212c33,85)and isColor(678,82,0x1a92ed,85)and isColor(707,80,0x1a92ed,85)and isColor(436,93,0x212c33,85)) then
		nLog("userName:"..userName..";userLevel:"..userLevel..";vip88:"..vip88)
		run.xLog("userName:"..userName..";userLevel:"..userLevel..";vip88:"..vip88)
		liveRetryTimes = 0
		return
	end
	liveRetryTimes = liveRetryTimes + 1
end

function openWangwang()
	runApp("com.taobao.iteam.ios.aliwangwang")
	mSleep(1500)
	local retryTimes = 0
	while true do
		-- 3749.png
		if(isColor(171,88,0x1a92ed,85)and isColor(250,90,0x1a92ed,85)and isColor(505,103,0x1a92ed,85))then
			-- wangxin shouye
			randomTap(369,1285)
			mSleep(1000)
			randomTap(703,91)
			mSleep(1000)
			randomTap(449,207)  -- 随机点击输入旺旺账号
			mSleep(1000)
			return true
		end
		-- 3751.png
		if(isColor(73,577,0x1cbd20,85)and isColor(60,553,0xffffff,85)and isColor(44,540,0x1cbd20,85))then
			-- add friend menu
			randomTap(514,212)  -- 随机点击输入旺旺账号
			mSleep(1000)
			return true
		end
		-- 3754.png
		if(isColor(678,83,0x1a92ed,85)and isColor(327,72,0x212c33,85)and isColor(401,87,0x212c33,85)and isColor(436,92,0x212c33,85))then
			-- friend menu
			randomTap(37,81) -- 左上角返回箭头
			mSleep(1000)
			randomTap(592,211) -- 随机点击输入旺旺账号
			mSleep(1000)
			return true
		end
		retryTimes = retryTimes + 1
		if retryTimes >= 10 then
			closeApp("com.taobao.iteam.ios.aliwangwang")
			mSleep(1500)
			return false
		end
		nLog("check open wangwang")
		mSleep(500)
	end
end

-- 检查错误
function checkErrorTips()
	-- 3753.png 淘口令提示
	if(isColor(140,405,0xffffff,85)and isColor(582,405,0xffffff,85)and isColor(561,788,0xffffff,85)and isColor(173,804,0xffffff,85)and isColor(376,640,0xf96324,85))then
		randomTap(374,986)
		mSleep(1500)
	end	
	-- 关闭提示关注的框框 3764.png
	if(isColor(693,66,0xdddddd,85)and isColor(312,716,0xff295f,85)and isColor(481,703,0xff2c76,85)and isColor(364,777,0x2a2a2a,85))then
		randomTap(371,887)
		mSleep(1500)
	end
end

-- 检查是直播，而不是录像
function checkLive()
	-- 录像 3755.png
	if(isColor(225,1288,0xffffff,85)and isColor(55,1291,0xffffff,85)and isColor(691,1308,0xffffff,85)and isColor(256,1291,0x828483,85))then
		return false
	end
	-- 直播结束 3756.png
	if(isColor(158,333,0x363b47,85)and isColor(613,342,0x363b47,85)and isColor(617,566,0x363b47,85)and isColor(93,566,0x363b47,85)and isColor(384,671,0xffffff,85))then
		return false
	end
	-- app的首页 3757.png
	if(isColor(178,98,0xffffff,85)and isColor(130,102,0xffffff,85)and isColor(53,74,0xffffff,85)and isColor(690,75,0xfff3f5,85)and isColor(737,202,0xff1b3f,85))then
		-- 往下拉动
		moveTo(355,434,445,820,35)
		run.mRndSleep(2000,3000)
		-- 选取精选  可能会有我的关注，所以精选的位置不是固定的 3759.png
		if(isColor(696,226,0xffb5bc,85)and isColor(9,453,0xff3850,85)and isColor(736,443,0xff163c,85))then
			-- 有关注
			moveTo(196,742,533,762,25)
			run.mRndSleep(500,1000)
			-- 点击精选
			randomTap(153,738)
			run.mRndSleep(2000,3000)
			-- 选取第二个直播
			randomTap(568,993)
			run.mRndSleep(2000,3000)
		else
			-- 没关注
			moveTo(205,531,155,534,25)
			run.mRndSleep(500,1000)
			-- 点击精选
			randomTap(153,529)
			run.mRndSleep(2000,3000)
			-- 选取第二个直播
			randomTap(551,780)
			run.mRndSleep(2000,3000)
		end
		return true
	end
	-- 正常的直播 3744.png
	if(isColor(683,1280,0xffffff,85)and isColor(587,1282,0xfcf2f4,85)and isColor(59,1272,0xff3164,85))then
		return true
	end
	snapAndSave()
	-- 其他未知情况
	return false
end


while true do
	for k in pairs(userLevelSign) do
		keepScreen(false)
		if appIsRunning("com.taobao.live") == 1 then
			-- 正在前台或者后台运行
			runApp("com.taobao.live")
			mSleep(2000)
		else
			runApp("com.taobao.live")
			mSleep(5000)
		end                                                                                                                                   
		-- 检查错误，如淘口令提示
		checkErrorTips()
		-- 检查是否直播
		liveRes = checkLive()
		if liveRes == false then
			toast("不是直播 ！")
			closeApp("com.taobao.live")
			mSleep(3000)
		else
			-- 检查错误，如淘口令提示
			checkErrorTips()
			mSleep(1000)
			keepScreen(true)
			nLog("begin find image:"..userLevelSign[k])
			x, y = findImage(userLevelSign[k],33,816,405,1069, 400000)
			if x ~= -1 then
				getNameByOcr(k)
			else
				liveRetryTimes = liveRetryTimes + 1
				if liveRetryTimes >= 20 then
					-- 失败次数过多，关闭app
					liveRetryTimes = 0
					closeApp("com.taobao.live")
					mSleep(2000)
				end
			end
		end
		mSleep(1000)
	end
end




-- 6/6s/7/8750x1334