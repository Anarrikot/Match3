math.randomseed(os.clock())
local clock = os.clock

local ROWS = 10 -- Количество строк 
local COLUMNS = 10 -- Количество колонок
local COLORS = {"A", "B", "C", "D", "E", "F"} -- Цвета
local map = {} -- Игровое поле

function init() -- Функция создания поля
	for i = 1, ROWS do
		map[i]={}
		for j = 1, COLUMNS do
			local temp =COLORS[math.random(#COLORS)]
			while (isMatch(i, j, temp, true)) do -- Проверяем не появятся ли готовая тройка в строке
				temp =COLORS[math.random(#COLORS)]
			end
			map[i][j]=temp
		end
	end
end

function dump() -- Функция отображения поля 
	io.write("  0 1 2 3 4 5 6 7 8 9\n")
	io.write("  - - - - - - - - - -\n")
	for i = 1, ROWS do
		io.write(i-1 .. "|")
		for j = 1, COLUMNS do
			io.write(map[i][j] .. " ")
		end
		io.write("\n")
	end
	
	local t0 = clock() -- Задержка перед выводом
	while clock() - t0 <= 0.3 do end 
	
end

function goDown() -- Функция смещения криссталов вниз
	local isDo = false
	for i = ROWS, 1, -1 do
		for j = 1, COLUMNS do
			if (i == 1 and map[i][j] == " ") then
				map[i][j] =COLORS[math.random(#COLORS)]
				isDo=true
			elseif (i > 1 and map[i-1][j] == " " and map[i][j] == " ") then
				local temp = i
				while (map[temp][j] == " ") do
					temp=temp-1
					if (temp < 1) then 
						temp = 1
						map[temp][j] = COLORS[math.random(#COLORS)]
					end
				end
				map[i][j], map[temp][j] = map[temp][j], map[i][j]
				isDo=true
			elseif (map[i][j] == " ") then
				map[i-1][j], map[i][j] = map[i][j], map[i-1][j]
				isDo=true
			end
		end
		if isDo then
			dump()
			isDo=false
		end
	end
end

function isMatch(x, y, value, init) -- Функция для проверки появится ли готовая тройка
	if (x>2 and map[x-1][y] == map[x-2][y] and map[x-1][y] == value) then
		return true, x, y
	end
	if (y>2 and map[x][y-1] == map[x][y-2] and map[x][y-1] == value) then
		return true, x, y
	end
	if (not init) then
		if ((x>1 and x<ROWS) and map[x+1][y] == value and map[x-1][y] == value) then
			return true, x, y
		end
		if ((y>1 and y<COLUMNS) and map[x][y+1] == value and map[x][y-1] == value) then
			return true, x, y
		end
		if (x<ROWS-1 and map[x+1][y] == map[x+2][y] and map[x+1][y] == value) then
			return true, x, y
		end
		if (y<COLUMNS-1 and map[x][y+1] == map[x][y+2] and map[x][y+1] == value) then
			return true, x, y
		end
	end
	return false
end

function isMatchInMap() -- Функция для проверки есть ли готовые тройки на поле
	local isDel = false
	for i = 1, ROWS do
		for j = 1, COLUMNS do
			if isMatch(i, j, map[i][j]) then
				isDel, x, y = isMatch(i, j, map[i][j])
				break
			end
		end
		if isDel then
			break
		end
	end
	return isDel, x, y
end
 
function checkMove() -- Функция для проверки есть ли ход
	local isMove = false
	for i = 1, ROWS do
		for j = 1, COLUMNS do
			if (i<ROWS) then
				map[i][j], map[i + 1][j] = map[i + 1][j], map[i][j]
				if (isMatch(i + 1, j, map[i + 1][j]) or isMatch(i, j, map[i][j])) then
					isMove = true
				end
				map[i][j], map[i + 1][j] = map[i + 1][j], map[i][j]
			end
			if (j<COLUMNS) then
				map[i][j], map[i][j + 1] = map[i][j + 1], map[i][j]
				if (isMatch(i, j + 1, map[i][j + 1]) or isMatch(i, j, map[i][j])) then
					isMove = true
				end
				map[i][j], map[i][j + 1] = map[i][j + 1], map[i][j]
			end
		end
	end
	return isMove
end

function tick() -- Функция выполнения действия на поле
	isDel, x, y = isMatchInMap()
	while(isDel) do
		local temp
		if(x<ROWS-1 and map[x][y]==map[x+1][y] and map[x+2][y]==map[x+1][y]) then
			temp = x
			while (temp<ROWS and map[temp][y]==map[temp+1][y]) do
				map[temp][y] = " "
				temp = temp + 1
			end
			map[temp][y] = " "
		end
		if(y<COLUMNS-1 and map[x][y]==map[x][y+1] and map[x][y+2]==map[x][y+1]) then
			temp = y
			while (temp<COLUMNS and map[x][temp]==map[x][temp+1]) do
				map[x][temp] = " "
				temp = temp + 1
			end
			map[x][temp] = " "
		end
		goDown()
		isDel, x, y = isMatchInMap()
	end
	while not checkMove() do
		io.write("Ходов нет, перемешивам\n")
		mix()
		dump()
	end
end

function move(from, to) -- Функция выполнение действия игрока
	if (from == nil or to == nil) then
		io.write("Неправильный ввод. Попробуйте снова\n")
		dump()
		return
	end
	local x, y, isFalse = from[1]+1, from[2]+1, true
	if (to == "l" and y > 1) then -- перемещение влево
        map[x][y], map[x][y - 1] = map[x][y - 1], map[x][y]
		if not(isMatch(x, y - 1,map[x][y - 1]) or isMatch(x, y,map[x][y])) then
			map[x][y], map[x][y - 1] = map[x][y - 1], map[x][y]
			isFalse = false
		end
    elseif (to == "r" and y < COLUMNS) then -- перемещение вправо
        map[x][y], map[x][y + 1] = map[x][y + 1], map[x][y]
		if not(isMatch(x, y + 1,map[x][y + 1]) or isMatch(x, y,map[x][y])) then
			map[x][y], map[x][y + 1] = map[x][y + 1], map[x][y]
			isFalse = false
		end
    elseif (to == "u" and x > 1) then -- перемещение вверх
        map[x][y], map[x - 1][y] = map[x - 1][y], map[x][y]
		if not(isMatch(x - 1, y,map[x - 1][y]) or isMatch(x, y,map[x][y])) then
			map[x][y], map[x - 1][y] = map[x - 1][y], map[x][y]
			isFalse = false
		end
    elseif (to == "d" and x < ROWS) then -- перемещение вниз
        map[x][y], map[x + 1][y] = map[x + 1][y], map[x][y]
		if not(isMatch(x + 1, y,map[x + 1][y]) or isMatch(x, y,map[x][y])) then
			map[x][y], map[x + 1][y] = map[x + 1][y], map[x][y]
			isFalse = false
		end
	else
		isFalse = false
	end
	if not (isFalse) then
		io.write("Неправильный ход. Попробуйте снова\n")
		dump()
	end
end

function mix() --Перемешивание поля
	for i = 1, ROWS do
		for j = 1, COLUMNS do
			local x = math.random(#map)
			local y = math.random(#map[1])
			while (isMatch(x,y, map[i][j]) or isMatch(i,j, map[x][y])) do -- Проверяем не появятся ли готовая тройка в строке
				x = math.random(#map)
				y = math.random(#map[1])
			end
			map[i][j], map[x][y] = map[x][y], map[i][j]
		end
	end
end

function main() --Основной цикл
	init()
	dump()
		while not checkMove() do
		io.write("Ходов нет, перемешивам\n")
		mix()
		dump()
	end
	while(true) do
		print("Введите ход x y d (x-строка y-столбец d-направление) или q (выход)")
		local line = io.read()
		if(line=="q") then -- Выход из программы
			break
		end
		local x, y, d = line:match("(%d) (%d) (%a)") -- Разбиение строки ввода 
		move({x,y}, d)
		tick()
	end
end

main()