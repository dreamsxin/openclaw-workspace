# UTF-8 source. HeroMainView/HeroDetailInfoView split from main.gd using source prefab inventories.
extends RefCounted

const DEFAULT_HERO_ID := 240030
const UI_HERO_BG_MAIN := "res://assets/ui/background/hero_bg_01.png"
const UI_HERO_BG_STAR := "res://assets/ui/background/hero_bg_01_star.png"
const UI_HERO_BG_DETAIL := "res://assets/ui/background/hero_bg_10.png"
const UI_HERO_DETAIL_INFO_BG := "res://assets/ui/background/guessing_bg_03.png"
const UI_HERO_SELECTOR_BG := "res://assets/ui/hero/hero_img_36.png"
const UI_HERO_SELECTOR_TOP := "res://assets/ui/hero/hero_img_36a.png"
const UI_HERO_SORT_BTN := "res://assets/ui/hero/hero_btn_05.png"
const UI_HERO_FILTER_BG := "res://assets/ui/hero/hero_img_108.png"
const UI_HERO_HIGHLIGHT := "res://assets/ui/hero/hero_img_119.png"
const UI_HERO_STAR_SMALL := "res://assets/ui/hero/hero_img_60.png"
const UI_HERO_LIST_TOP_BTN := "res://assets/ui/hero/hero_btn_01.png"
const UI_HERO_LIST_TOP_ICON_FORMATION := "res://assets/ui/hero/hero_img_01.png"
const UI_HERO_LIST_TOP_ICON_RECOMMEND := "res://assets/ui/hero/hero_img_03.png"
const UI_HERO_LIST_SORT_BG := "res://assets/ui/hero/hero_img_04.png"
const UI_HERO_LIST_SORT_DIVIDER := "res://assets/ui/hero/hero_img_05.png"
const UI_HERO_LIST_TAB_NORMAL := "res://assets/ui/common/common_btn_08.png"
const UI_HERO_LIST_CAMP_ICONS := [
	"res://assets/ui/hero/hero_img_122.png",
	"res://assets/ui/hero/hero_img_123.png",
	"res://assets/ui/hero/hero_img_124.png",
	"res://assets/ui/hero/hero_img_126.png",
	"res://assets/ui/hero/hero_img_125.png",
	"res://assets/ui/hero/hero_img_167.png",
]
const UI_HERO_LIST_CAMP_HIGHLIGHT_ICONS := [
	"res://assets/ui/hero/hero_img_127.png",
	"res://assets/ui/hero/hero_img_128.png",
	"res://assets/ui/hero/hero_img_129.png",
	"res://assets/ui/hero/hero_img_131.png",
	"res://assets/ui/hero/hero_img_130.png",
	"res://assets/ui/hero/hero_img_168.png",
]
const UI_HERO_CAMP_FILTER_ICONS := [
	"res://assets/ui/hero/hero_img_109.png",
	"res://assets/ui/hero/hero_img_110.png",
	"res://assets/ui/hero/hero_img_111.png",
	"res://assets/ui/hero/hero_img_112.png",
	"res://assets/ui/hero/hero_img_113.png",
	"res://assets/ui/hero/hero_img_114.png",
]
const UI_HERO_OCCUPATION_FILTER_ICONS := [
	"res://assets/ui/hero/hero_img_109.png",
	"res://assets/ui/hero/hero_img_115.png",
	"res://assets/ui/hero/hero_img_116.png",
	"res://assets/ui/hero/hero_img_117.png",
	"res://assets/ui/hero/hero_img_118.png",
	"res://assets/ui/hero/hero_img_199.png",
]
const UI_COMMON_BTN_GOLD := "res://assets/ui/common/tongyong_btn_08.png"
const UI_COMMON_BTN_WHITE := "res://assets/ui/common/tongyong_btn_01.png"
const UI_COMMON_TAB_HIGHLIGHT := "res://assets/ui/common/common_btn_07.png"
const UI_COMMON_HEAD_FRAME := "res://assets/ui/common/common_img_07.png"
const UI_COMMON_LEVEL_BADGE := "res://assets/ui/common/common_img_61.png"
const UI_COMMON_HERO_HEAD_FRAME := "res://assets/ui/common/common_img_64.png"
const UI_COMMON_HERO_STAR_BAR := "res://assets/ui/common/common_img_62.png"
const UI_COMMON_RARE_BADGE := "res://assets/ui/common/common_img_163.png"
const UI_COMMON_STAR := "res://assets/ui/common/common_img_73.png"
const UI_COMMON_STAR_OFF := "res://assets/ui/common/common_img_74.png"
const UI_COMMON_WAIT_BG := "res://assets/ui/common/common_img_59.png"
const UI_COMMON_RED_DOT := "res://assets/ui/common/common_img_17.png"
const UI_COMMON_ITEM_FRAME := "res://assets/ui/common/common_img_07.png"
const UI_COMMON_SECTION := "res://assets/ui/common/common_img_199.png"
const UI_COMMON_SKILL_FRAME := "res://assets/ui/common/common_img_208.png"
const UI_HERO_CARD_DI_FRAME := "res://assets/ui/hero/hero_img_287.png"
const UI_HERO_CARD_BG := "res://assets/ui/hero/hero_img_18.png"
const UI_HERO_CARD_FRAME := "res://assets/ui/hero/hero_img_19.png"
const UI_HERO_CARD_SPECIAL := "res://assets/ui/hero/hero_txt_01.png"
const UI_HERO_CARD_ACTIVATE := "res://assets/ui/hero/hero_txt_02.png"
const UI_HERO_ATTR_RARE := "res://assets/ui/hero/hero_img_58.png"
const UI_HERO_ATTR_INFO_BG := "res://assets/ui/hero/hero_img_62.png"
const UI_HERO_ATTR_LINE := "res://assets/ui/hero/hero_img_65.png"
const UI_HERO_ATTR_ROW_BG := "res://assets/ui/hero/hero_img_68.png"
const UI_HERO_ATTR_ATTACK := "res://assets/ui/hero/hero_img_69.png"
const UI_HERO_ATTR_HP := "res://assets/ui/hero/hero_img_70.png"
const UI_HERO_ATTR_DEFENSE := "res://assets/ui/hero/hero_img_71.png"
const UI_HERO_ATTR_SPEED := "res://assets/ui/hero/hero_img_72.png"
const UI_HERO_ATTR_DETAIL_BTN := "res://assets/ui/hero/hero_img_73.png"
const UI_HERO_SKILL_BG := "res://assets/ui/hero/hero_img_74.png"
const UI_HERO_SKILL_BTN := "res://assets/ui/hero/hero_img_75.png"
const UI_HERO_BIG_BTN_GOLD := "res://assets/ui/hero/hero_btn_06.png"
const UI_HERO_BIG_BTN_A := "res://assets/ui/hero/hero_btn_16.png"
const UI_HERO_BIG_BTN_B := "res://assets/ui/hero/hero_btn_17.png"
const UI_HERO_BIG_BTN_C := "res://assets/ui/hero/hero_btn_23.png"
const UI_HERO_SLUG_SMALL_BTN := "res://assets/ui/hero/hero_btn_32.png"
const UI_HERO_EQUIP_BG := "res://assets/ui/hero/hero_img_143.png"
const UI_HERO_EQUIP_SLOT_FX_A := "res://assets/ui/hero/hero_img_144.png"
const UI_HERO_EQUIP_SELECT := "res://assets/ui/hero/hero_img_145.png"
const UI_HERO_EQUIP_STRENGTH := "res://assets/ui/hero/hero_img_146.png"
const UI_HERO_EQUIP_STRENGTH_ICON := "res://assets/ui/hero/hero_img_299.png"
const UI_HERO_EQUIP_STRENGTH_TITLE := "res://assets/ui/hero/hero_img_296.png"
const UI_HERO_EQUIP_LEVEL_RING := "res://assets/ui/hero/hero_img_156.png"
const UI_HERO_WEAPON_EMPTY_ICON := "res://assets/ui/hero/hero_img_164.png"
const UI_HERO_SLUG_BG := "res://assets/ui/hero/hero_img_173.png"
const UI_HERO_SLUG_FX_A := "res://assets/ui/hero/hero_img_173a.png"
const UI_HERO_SLUG_FX_B := "res://assets/ui/hero/hero_img_173b.png"
const UI_HERO_SLUG_FX_C := "res://assets/ui/hero/hero_img_173c.png"
const UI_HERO_SLUG_FX_D := "res://assets/ui/hero/hero_img_173d.png"
const UI_HERO_SLUG_FX_E := "res://assets/ui/hero/hero_img_173e.png"
const UI_HERO_SLUG_FX_F := "res://assets/ui/hero/hero_img_173f.png"
const UI_HERO_SLUG_FX_H := "res://assets/ui/hero/hero_img_173h.png"
const UI_HERO_SLUG_FX_I := "res://assets/ui/hero/hero_img_173i.png"
const UI_HERO_SLUG_FX_J := "res://assets/ui/hero/hero_img_173j.png"
const UI_HERO_SLUG_FX_K := "res://assets/ui/hero/hero_img_173k.png"
const UI_HERO_SLUG_SPARK := "res://assets/ui/hero/hero_img_173s.png"
const UI_HERO_SLUG_MID := "res://assets/ui/hero/hero_img_174.png"
const UI_HERO_SLUG_MID_A := "res://assets/ui/hero/hero_img_174a.png"
const UI_HERO_SLUG_MID_B := "res://assets/ui/hero/hero_img_174b.png"
const UI_HERO_SLUG_MID_C := "res://assets/ui/hero/hero_img_174c.png"
const UI_HERO_SLUG_ICON := "res://assets/ui/hero/hero_img_175.png"
const UI_HERO_SLUG_SLOT := "res://assets/ui/hero/hero_img_176.png"
const UI_HERO_SLUG_SLOT_MAIN := "res://assets/ui/hero/hero_img_177.png"
const UI_HERO_SLUG_LIMIT_TYPE := "res://assets/ui/hero/hero_img_178.png"
const UI_HERO_SLUG_NAME_BG := "res://assets/ui/hero/hero_img_179.png"
const UI_HERO_SLUG_LIMIT_BG := "res://assets/ui/hero/hero_img_182.png"
const UI_HERO_SLUG_MANUAL := "res://assets/ui/hero/hero_img_183.png"
const UI_HERO_SLUG_DRAW := "res://assets/ui/hero/hero_img_184.png"
const UI_HERO_SLUG_TAB_SELECT := "res://assets/ui/hero/hero_img_185.png"
const UI_HERO_SLUG_TAB_BASE := "res://assets/ui/hero/hero_img_186.png"
const UI_HERO_SLUG_TAB_LINE := "res://assets/ui/hero/hero_img_187.png"
const UI_HERO_SLUG_PASS := "res://assets/ui/hero/hero_img_298.png"
const UI_HERO_SLUG_INFO_MAIN := "res://assets/ui/hero/hero_img_322.png"
const UI_HERO_SLUG_INFO_SUB := "res://assets/ui/hero/hero_img_323.png"
const UI_HERO_STAGE_BG := "res://assets/ui/hero/hero_img_203.png"
const UI_HERO_STAGE_STEP_ON := "res://assets/ui/hero/hero_img_96.png"
const UI_HERO_STAGE_STEP_OFF := "res://assets/ui/hero/hero_img_93.png"
const UI_HERO_STAGE_STEP_AURA := "res://assets/ui/hero/hero_img_93a.png"
const UI_HERO_STAGE_LINE := "res://assets/ui/hero/hero_img_98.png"
const UI_ITEM_DRAW_02 := "res://assets/ui/item/draw_02.png"
const UI_HERO_CORE_DI_01 := "res://assets/ui/hero/hero_core_di_01.png"
const UI_HERO_CORE_DI_02 := "res://assets/ui/hero/hero_core_di_02.png"
const UI_HERO_CORE_DI_03 := "res://assets/ui/hero/hero_core_di_03.png"
const UI_HERO_CORE_DI_04 := "res://assets/ui/hero/hero_core_di_04.png"
const UI_HERO_CORE_BTN_01 := "res://assets/ui/hero/hero_core_btn_01.png"
const HERO_MAIN_BG_POS := Vector2(0, 0)
const HERO_MAIN_BG_SIZE := Vector2(1670, 750)
const HERO_SELECTOR_PANEL_POS := Vector2(36, 90)
const HERO_SELECTOR_PANEL_SIZE := Vector2(100, 640)
const HERO_SELECTOR_SORT_POS := Vector2(59, 633)
const HERO_LIST_TAB_SIZE := Vector2(206, 62)
const HERO_LIST_ORDINATION_TAB_SIZE := Vector2(111, 44)
const HERO_LIST_FILTER_PANEL_POS := Vector2(836, 82)
const HERO_LIST_FILTER_PANEL_SIZE := Vector2(360, 130)
const HERO_LIST_LEFT_TAB_POS := Vector2(24, 151)
const HERO_LIST_LEFT_TAB_STEP := 89.0
const HERO_LIST_SCROLL_POS := Vector2(461, 92)
const HERO_LIST_SCROLL_SIZE := Vector2(978, 658)
const HERO_LIST_ROW_SIZE := Vector2(978, 296)
const HERO_LIST_CARD_SIZE := Vector2(172, 297)
const HERO_LIST_CARDS_PER_ROW := 5
const HERO_LIST_CARD_START_X := 11.0
const HERO_LIST_CARD_GAP := 24.0
const HERO_LIST_TOP_BUTTON_POS := Vector2(691, 24)
const HERO_LIST_SORT_POS := Vector2(1011, 24)
const HERO_DETAIL_STAGE_POS := Vector2(205, 0)
const HERO_DETAIL_STAGE_SIZE := Vector2(1060, 750)
const HERO_LEFT_FUNC_TAB_POS := Vector2(167, 120)
const HERO_LEFT_FUNC_TAB_SIZE := Vector2(161, 500)
const HERO_LEFT_FUNC_TAB_ITEM_H := 60.0
const HERO_CORE_PANEL_POS := Vector2(1134, 0)
const HERO_CORE_PANEL_SIZE := Vector2(536, 750)
const HERO_DETAIL_FILTER_POS := Vector2(355, 106)
const HERO_DETAIL_INFO_POS := Vector2(958, 64)
const HERO_DETAIL_TAB_POS := Vector2(988, 26)
const HERO_DETAIL_INFO_SCALE := 0.5
const HERO_DETAIL_INFO_SIZE := Vector2(1080, 610) * HERO_DETAIL_INFO_SCALE
const HERO_DETAIL_INFO_MODAL_POS := Vector2(295, 70)
const HERO_DETAIL_INFO_MODAL_SIZE := Vector2(1080, 610)
const UI_MAIN_LIMIT_ICONS := [
	"res://assets/ui/mainui/mainui_btn_15.png",
	"res://assets/ui/mainui/mainui_btn_16.png",
	"res://assets/ui/mainui/mainui_btn_17.png",
	"res://assets/ui/mainui/mainui_btn_20.png",
	"res://assets/ui/mainui/mainui_btn_18.png",
	"res://assets/ui/mainui/mainui_btn_19.png"
]

var app
var gallery_filter := "all"
var gallery_sort_mode := "level"
var gallery_sort_open := false
var gallery_camp_filter := "all"
var gallery_occupation_filter := "all"
var hero_detail_tab := "overview"

func _init(app_ref) -> void:
	app = app_ref

func _show_gallery() -> void:
	app._clear("幻靈")
	_draw_hero_list_background()
	_draw_hero_list_header()
	_draw_hero_list_filters()
	_draw_hero_list_cards()
	_draw_hero_sort_panel()

func _draw_hero_list_background() -> void:
	app._draw_image(UI_HERO_BG_MAIN, Vector2(0, 0), app.CANVAS_SIZE, true, Color(1, 1, 1, 0.96))
	app._draw_image(UI_HERO_BG_MAIN, Vector2(0, 0), app.CANVAS_SIZE, true, Color(1, 1, 1, 0.16))
	app._draw_image(UI_HERO_BG_STAR, Vector2(0, 0), app.CANVAS_SIZE, true, Color(1, 1, 1, 0.30))
	app._draw_image("res://assets/ui/common/common_btn_06.png", Vector2(52, 100), Vector2(8, 610), true, Color(1, 1, 1, 0.86))


func _draw_hero_list_header() -> void:
	_draw_hero_top_button("编队", UI_HERO_LIST_TOP_ICON_FORMATION, HERO_LIST_TOP_BUTTON_POS, func() -> void:
		_show_gallery_notice("编队", "本地 MVP 已保留编队入口，阵容编辑将在战斗队列模块接入。")
	)
	_draw_hero_top_button("阵容推荐", UI_HERO_LIST_TOP_ICON_RECOMMEND, HERO_LIST_TOP_BUTTON_POS + Vector2(160, 0), func() -> void:
		_show_gallery_notice("阵容推荐", "本地 MVP 已根据当前幻靈数据排序展示，推荐算法暂以战力/稀有度替代。")
	)

	app._draw_image(UI_HERO_LIST_SORT_BG, HERO_LIST_SORT_POS, Vector2(473, 44), false, Color(1, 1, 1, 0.94))
	for divider_x in [128.0, 236.5, 345.0]:
		app._draw_image(UI_HERO_LIST_SORT_DIVIDER, HERO_LIST_SORT_POS + Vector2(divider_x, 13), Vector2(2, 18), false, Color(1, 1, 1, 0.72))
	var modes := [
		{"key": "level", "text": "等级"},
		{"key": "rarity", "text": "稀有"},
		{"key": "power", "text": "战力"},
		{"key": "name", "text": "名称"},
	]
	for index in range(modes.size()):
		var mode: Dictionary = modes[index]
		var mode_key := str(mode.get("key", "power"))
		var target_mode := mode_key
		_draw_hero_ordination_tab(str(mode.get("text", "")), HERO_LIST_SORT_POS + Vector2(index * 118.25, 0), gallery_sort_mode == mode_key, func() -> void:
			gallery_sort_mode = target_mode
			_show_gallery()
		)


func _draw_hero_top_button(text: String, icon_path: String, pos: Vector2, on_press: Callable) -> void:
	app._draw_image(UI_HERO_LIST_TOP_BTN, pos, Vector2(150, 44), false, Color(1, 1, 1, 0.94))
	app._draw_image(icon_path, pos + Vector2(12, 0), Vector2(44, 44), false, Color(1, 1, 1, 0.92))
	var label: Label = app._label(text, 18, HORIZONTAL_ALIGNMENT_CENTER)
	label.position = pos + Vector2(35, 3)
	label.size = Vector2(112, 36)
	label.modulate = Color(0.38, 0.27, 0.18)
	app._view_container().add_child(label)
	app._add_hit_button(pos, Vector2(150, 44), on_press)


func _show_gallery_notice(title: String, body: String) -> void:
	_show_gallery()
	app._view_container().add_child(app._panel(Vector2(0, 0), app.CANVAS_SIZE, Color(0, 0, 0, 0.42)))
	app._view_container().add_child(app._panel(Vector2(515, 236), Vector2(460, 210), Color(0.075, 0.056, 0.048, 0.96)))
	var heading: Label = app._label(title, 26, HORIZONTAL_ALIGNMENT_CENTER)
	heading.position = Vector2(555, 260)
	heading.size = Vector2(380, 38)
	app._view_container().add_child(heading)
	var message: Label = app._label(body, 18, HORIZONTAL_ALIGNMENT_CENTER)
	message.position = Vector2(555, 314)
	message.size = Vector2(380, 56)
	message.modulate = Color(0.92, 0.86, 0.78)
	app._view_container().add_child(message)
	app._add_action_button("確定", Vector2(684, 388), _show_gallery, Vector2(122, 42), UI_COMMON_BTN_GOLD)


func _draw_hero_sort_panel() -> void:
	if not gallery_sort_open:
		return
	app._draw_image(UI_HERO_FILTER_BG, HERO_LIST_FILTER_PANEL_POS, HERO_LIST_FILTER_PANEL_SIZE, false, Color(1, 1, 1, 0.96))
	app._view_container().add_child(app._panel(Vector2(848, 92), Vector2(336, 106), Color(0.030, 0.024, 0.038, 0.72)))
	var modes := [
		{"key": "level", "text": "等級"},
		{"key": "power", "text": "戰力"},
		{"key": "rarity", "text": "稀有"},
	]
	for index in range(modes.size()):
		var mode: Dictionary = modes[index]
		var mode_key := str(mode.get("key", "power"))
		var selected := gallery_sort_mode == mode_key
		var pos := Vector2(852 + index * 112.0, 92)
		var target_mode := mode_key
		_draw_hero_ordination_tab(str(mode.get("text", "")), pos, selected, func() -> void:
			gallery_sort_mode = target_mode
			gallery_sort_open = false
			_show_gallery()
		)
	var occupation_keys := ["all", "occupation1", "occupation2", "occupation3", "occupation4", "occupation5"]
	for index in range(occupation_keys.size()):
		var key := str(occupation_keys[index])
		var pos := Vector2(862 + index * 48.0, 138)
		var target_occupation := key
		_draw_hero_filter_icon(key, gallery_occupation_filter == key, str(UI_HERO_OCCUPATION_FILTER_ICONS[index]), pos, Vector2(36, 36), "全" if index == 0 else "", func() -> void:
			gallery_occupation_filter = target_occupation
			_show_gallery()
		)

	var camp_keys := ["all", "camp1", "camp2", "camp3", "camp4", "camp5"]
	for index in range(camp_keys.size()):
		var key := str(camp_keys[index])
		var pos := Vector2(862 + index * 48.0, 174)
		var target_camp := key
		_draw_hero_filter_icon(key, gallery_camp_filter == key, str(UI_HERO_CAMP_FILTER_ICONS[index]), pos, Vector2(36, 36), "全" if index == 0 else "", func() -> void:
			gallery_camp_filter = target_camp
			_show_gallery()
		)


func _draw_hero_ordination_tab(text: String, pos: Vector2, selected: bool, on_press: Callable) -> void:
	if selected:
		app._view_container().add_child(app._panel(pos + Vector2(8, 6), HERO_LIST_ORDINATION_TAB_SIZE - Vector2(16, 12), Color(0.72, 0.48, 0.20, 0.30)))
		app._view_container().add_child(app._panel(pos + Vector2(22, 36), Vector2(HERO_LIST_ORDINATION_TAB_SIZE.x - 44, 3), Color(1.0, 0.74, 0.30, 0.92)))
	var label: Label = app._label(text, 20, HORIZONTAL_ALIGNMENT_CENTER)
	label.position = pos
	label.size = HERO_LIST_ORDINATION_TAB_SIZE
	label.modulate = Color(1.0, 0.92, 0.70) if selected else Color(0.88, 0.84, 0.82)
	app._view_container().add_child(label)
	app._add_hit_button(pos, HERO_LIST_ORDINATION_TAB_SIZE, on_press)


func _draw_hero_filter_icon(_key: String, active: bool, icon_path: String, pos: Vector2, size: Vector2, text: String, on_press: Callable) -> void:
	if active:
		app._draw_image(UI_HERO_HIGHLIGHT, pos - Vector2(6, 6), size + Vector2(12, 12), false, Color(1.0, 0.82, 0.32, 0.62))
	app._draw_image(icon_path, pos, size, false, Color(1, 1, 1, 0.94))
	if not text.is_empty():
		var label: Label = app._label(text, 13, HORIZONTAL_ALIGNMENT_CENTER)
		label.position = pos + Vector2(-2, 9)
		label.size = Vector2(40, 18)
		app._view_container().add_child(label)
	app._add_hit_button(pos - Vector2(6, 6), size + Vector2(12, 12), on_press)


func _draw_hero_list_filters() -> void:
	var tabs := [
		{"text": "全部", "filter": "all", "icon": UI_HERO_LIST_CAMP_ICONS[0], "selected_icon": UI_HERO_LIST_CAMP_HIGHLIGHT_ICONS[0]},
		{"text": "虚光", "filter": "camp1", "icon": UI_HERO_LIST_CAMP_ICONS[1], "selected_icon": UI_HERO_LIST_CAMP_HIGHLIGHT_ICONS[1]},
		{"text": "绝舞", "filter": "camp2", "icon": UI_HERO_LIST_CAMP_ICONS[2], "selected_icon": UI_HERO_LIST_CAMP_HIGHLIGHT_ICONS[2]},
		{"text": "灼炎", "filter": "camp3", "icon": UI_HERO_LIST_CAMP_ICONS[3], "selected_icon": UI_HERO_LIST_CAMP_HIGHLIGHT_ICONS[3]},
		{"text": "逆卫", "filter": "camp4", "icon": UI_HERO_LIST_CAMP_ICONS[4], "selected_icon": UI_HERO_LIST_CAMP_HIGHLIGHT_ICONS[4]},
		{"text": "星殿", "filter": "camp5", "icon": UI_HERO_LIST_CAMP_ICONS[5], "selected_icon": UI_HERO_LIST_CAMP_HIGHLIGHT_ICONS[5]},
	]
	for index in range(tabs.size()):
		var tab: Dictionary = tabs[index]
		_draw_hero_list_tab(str(tab.get("text", "")), str(tab.get("filter", "")), str(tab.get("icon", "")), str(tab.get("selected_icon", "")), HERO_LIST_LEFT_TAB_POS + Vector2(0, index * HERO_LIST_LEFT_TAB_STEP))


func _draw_hero_list_tab(text: String, filter: String, icon_path: String, selected_icon_path: String, pos: Vector2) -> void:
	var selected := gallery_filter == filter
	app._draw_image(UI_COMMON_TAB_HIGHLIGHT if selected else UI_HERO_LIST_TAB_NORMAL, pos, Vector2(206, 64), false, Color(1, 1, 1, 0.96 if selected else 0.70))
	app._draw_image(selected_icon_path if selected else icon_path, pos + Vector2(80, 1), Vector2(63, 63), false, Color(1, 1, 1, 0.92 if selected else 0.70))

	var label: Label = app._label(text, 22, HORIZONTAL_ALIGNMENT_CENTER)
	label.position = pos + Vector2(116, 16)
	label.size = Vector2(88, 32)
	label.modulate = Color(1.0, 0.92, 0.78) if selected else Color(0.86, 0.82, 0.78)
	app._view_container().add_child(label)

	var button := Button.new()
	button.text = ""
	button.flat = true
	button.position = pos
	button.size = HERO_LIST_TAB_SIZE
	button.focus_mode = Control.FOCUS_NONE
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.pressed.connect(func() -> void:
		gallery_filter = filter
		_show_gallery()
	)
	app._view_container().add_child(button)


func _draw_hero_list_cards() -> void:
	var filtered: Array = _gallery_filtered_heroes()
	var scroll := ScrollContainer.new()
	scroll.position = HERO_LIST_SCROLL_POS
	scroll.size = HERO_LIST_SCROLL_SIZE
	scroll.clip_contents = true
	scroll.mouse_filter = Control.MOUSE_FILTER_PASS
	app._view_container().add_child(scroll)

	var row_count: int = maxi(1, int(ceil(float(filtered.size()) / float(HERO_LIST_CARDS_PER_ROW))))
	var content := Control.new()
	content.custom_minimum_size = Vector2(HERO_LIST_SCROLL_SIZE.x, maxf(HERO_LIST_SCROLL_SIZE.y, float(row_count) * HERO_LIST_ROW_SIZE.y))
	content.size = content.custom_minimum_size
	content.mouse_filter = Control.MOUSE_FILTER_PASS
	scroll.add_child(content)

	if filtered.is_empty():
		var empty: Label = _card_label("暫無符合條件的幻靈", Vector2(0, 284), Vector2(HERO_LIST_SCROLL_SIZE.x, 40), 22, HORIZONTAL_ALIGNMENT_CENTER, Color(0.92, 0.86, 0.78))
		content.add_child(empty)
		return

	for index in range(filtered.size()):
		var hero: Dictionary = filtered[index]
		var row_index: int = int(index / HERO_LIST_CARDS_PER_ROW)
		var col_index: int = index % HERO_LIST_CARDS_PER_ROW
		var pos := Vector2(HERO_LIST_CARD_START_X + col_index * (HERO_LIST_CARD_SIZE.x + HERO_LIST_CARD_GAP), row_index * HERO_LIST_ROW_SIZE.y)
		_draw_hero_list_card(hero, pos, content)


func _draw_hero_list_card(hero: Dictionary, pos: Vector2, parent: Control) -> void:
	var hero_id := int(hero.get("id", 0))
	var rarity := int(hero.get("rarity", 1))
	var level := int(app.save.get("hero_levels", {}).get(str(hero_id), 1))
	var copies := int(app.save.get("owned", {}).get(str(hero_id), 0))
	var shards := int(app.save.get("shards", {}).get(str(hero_id), 0))
	var owned := copies > 0
	var tint := Color(1, 1, 1, 1) if owned else Color(0.42, 0.42, 0.45, 1)
	_add_image_to(parent, UI_HERO_CARD_DI_FRAME, pos, Vector2(162, 282), false, Color(1, 1, 1, 0.96 if owned else 0.55))
	_add_image_to(parent, UI_HERO_CARD_BG, pos, HERO_LIST_CARD_SIZE, false, tint)
	_add_hero_card_portrait_to(parent, hero, pos + Vector2(6, 8), Vector2(160, 280), tint)
	_add_image_to(parent, UI_HERO_CARD_SPECIAL, pos + Vector2(62, 8), Vector2(98, 28), false, Color(1, 1, 1, 0.92 if owned else 0.44))
	_add_image_to(parent, "res://assets/ui/common/common_img_79.png", pos + Vector2(5, 5), Vector2(42, 42), false, Color(1, 1, 1, 0.94 if owned else 0.50))
	var camp_label: Label = _card_label(_hero_camp_short_label(hero), pos + Vector2(5, 14), Vector2(42, 20), 12, HORIZONTAL_ALIGNMENT_CENTER, Color(0.96, 0.88, 0.68) if owned else Color(0.66, 0.66, 0.68))
	parent.add_child(camp_label)
	_add_image_to(parent, UI_HERO_CARD_FRAME, pos + Vector2(6, 174), Vector2(160, 108), false, Color(1, 1, 1, 0.94 if owned else 0.56))
	_add_image_to(parent, "res://assets/ui/common/common_img_80.png", pos + Vector2(0, 174), Vector2(110, 54), false, Color(1, 1, 1, 0.88 if owned else 0.42))
	var rare_label: Label = _card_label("R%d" % rarity, pos + Vector2(18, 190), Vector2(48, 22), 16, HORIZONTAL_ALIGNMENT_CENTER, Color(1.0, 0.88, 0.54) if owned else Color(0.68, 0.66, 0.66))
	parent.add_child(rare_label)

	for i in range(5):
		var star_path := UI_COMMON_STAR if i < clamp(rarity, 1, 5) else UI_COMMON_STAR_OFF
		_add_image_to(parent, star_path, pos + Vector2(14 + i * 28.0, 205), Vector2(36, 36), false, Color(1, 1, 1, 0.95 if owned else 0.42))

	var state_text := "Lv.%d" % level
	if not owned:
		var cost := _hero_unlock_shard_cost(hero)
		state_text = "%d / %d" % [shards, cost]
	var level_label: Label = _card_label(state_text, pos + Vector2(74, 202), Vector2(90, 30), 20 if owned else 18, HORIZONTAL_ALIGNMENT_RIGHT, Color(1.0, 0.88, 0.56) if owned else Color(0.84, 0.80, 0.76))
	parent.add_child(level_label)
	if owned:
		var level_mark: Label = _card_label("等級", pos + Vector2(86, 207), Vector2(38, 18), 11, HORIZONTAL_ALIGNMENT_LEFT, Color(0.92, 0.82, 0.64))
		parent.add_child(level_mark)

	var display_name := str(hero.get("name", "Unknown")) if owned else "未獲得"
	var name_label: Label = _card_label(display_name, pos + Vector2(74, 250), Vector2(90, 25), 18, HORIZONTAL_ALIGNMENT_RIGHT, Color(1.0, 0.94, 0.82) if owned else Color(0.72, 0.70, 0.72))
	parent.add_child(name_label)
	if owned and copies > 1:
		var copy_label: Label = _card_label("+%d" % (copies - 1), pos + Vector2(10, 250), Vector2(42, 22), 15, HORIZONTAL_ALIGNMENT_CENTER, Color(1.0, 0.86, 0.48))
		parent.add_child(copy_label)
	if not owned:
		parent.add_child(_local_panel(pos, HERO_LIST_CARD_SIZE, Color(0.0, 0.0, 0.0, 0.18)))

	var button := Button.new()
	button.text = ""
	button.flat = true
	button.position = pos
	button.size = HERO_LIST_CARD_SIZE
	button.focus_mode = Control.FOCUS_NONE
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.pressed.connect(func() -> void:
		_show_hero_detail(hero_id)
	)
	parent.add_child(button)


func _local_panel(pos: Vector2, size: Vector2, color: Color) -> ColorRect:
	var panel := ColorRect.new()
	panel.position = pos
	panel.size = size
	panel.color = color
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return panel


func _card_label(text: String, pos: Vector2, size: Vector2, font_size: int, align: int, color: Color) -> Label:
	var label: Label = app._label(text, font_size, align)
	label.position = pos
	label.size = size
	label.modulate = color
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label


func _add_image_to(parent: Control, path: String, pos: Vector2, draw_size: Vector2, cover := false, tint := Color(1, 1, 1, 1)) -> TextureRect:
	var source_texture: Texture2D = app._load_png_source_texture(path)
	if source_texture == null:
		return null
	var rect := TextureRect.new()
	rect.texture = source_texture
	rect.position = pos
	rect.size = draw_size
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED if cover else TextureRect.STRETCH_SCALE
	rect.modulate = tint
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(rect)
	return rect


func _add_hero_round_thumb_to(parent: Control, hero: Dictionary, pos: Vector2, draw_size: Vector2, tint := Color(1, 1, 1, 1)) -> Control:
	var texture: Texture2D = app._hero_round_head_texture(hero)
	if texture == null:
		texture = app._hero_portrait_texture(hero)
	if texture == null:
		return null
	var rect := TextureRect.new()
	rect.texture = texture
	rect.position = pos
	rect.size = draw_size
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_SCALE if app._hero_round_head_path(hero) != "" else TextureRect.STRETCH_KEEP_ASPECT_COVERED
	rect.modulate = tint
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(rect)
	return rect


func _add_hero_card_portrait_to(parent: Control, hero: Dictionary, pos: Vector2, draw_size: Vector2, tint := Color(1, 1, 1, 1)) -> Control:
	var texture: Texture2D = app._hero_portrait_texture(hero)
	if texture == null:
		texture = app._hero_round_head_texture(hero)
	if texture == null:
		return null
	var clip := Control.new()
	clip.position = pos
	clip.size = draw_size
	clip.clip_contents = true
	clip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(clip)
	var rect := TextureRect.new()
	rect.texture = texture
	rect.position = Vector2.ZERO
	rect.size = draw_size
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	rect.modulate = tint
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip.add_child(rect)
	return clip


func _draw_hero_card_star_bar(parent: Control, rarity: int, pos: Vector2) -> void:
	_add_image_to(parent, UI_COMMON_HERO_STAR_BAR, pos, Vector2(104, 18), false, Color(1, 1, 1, 0.78))
	var count: int = clamp(rarity, 1, 5)
	var start_x := pos.x + (104.0 - float(count) * 17.0) * 0.5
	for i in range(count):
		_add_image_to(parent, UI_HERO_STAR_SMALL, Vector2(start_x + i * 17.0, pos.y + 1), Vector2(16, 16), false, Color(1, 1, 1, 0.95))

func _show_hero_detail(hero_id: int) -> void:
	var hero: Dictionary = app._hero_by_id(hero_id)
	app._clear(str(hero.get("name", "角色")))
	app.save["hero_detail_last_id"] = hero_id
	if hero_detail_tab == "overview":
		hero_detail_tab = "attrs"
	_draw_hero_detail_background()
	_draw_hero_selector_strip(hero_id)
	app._draw_hero_stage(hero, HERO_DETAIL_STAGE_POS, HERO_DETAIL_STAGE_SIZE, false)
	_draw_hero_main_function_tabs(hero)
	_draw_hero_main_core_panel(hero, HERO_CORE_PANEL_POS)
	_draw_hero_detail_notice(HERO_CORE_PANEL_POS + Vector2(22, HERO_CORE_PANEL_SIZE.y - 56))
	_draw_hero_detail_nav(hero_id)
	_draw_hero_detail_filter_panel(hero_id)

	var key := str(hero.get("id", 0))
	var copies := int(app.save.get("owned", {}).get(key, 0))
	var shards := int(app.save.get("shards", {}).get(key, 0))
	if copies <= 0:
		var mask: ColorRect = app._panel(HERO_DETAIL_STAGE_POS, HERO_DETAIL_STAGE_SIZE, Color(0.0, 0.0, 0.0, 0.42))
		app._view_container().add_child(mask)
		var locked: Label = app._label("未獲得", 36, HORIZONTAL_ALIGNMENT_CENTER)
		locked.position = HERO_DETAIL_STAGE_POS + Vector2(0, 270)
		locked.size = Vector2(HERO_DETAIL_STAGE_SIZE.x, 56)
		app._view_container().add_child(locked)
		app._add_action_button("前往喚靈", Vector2(1426, 636), app._show_gacha, Vector2(132, 44))
		if shards >= _hero_unlock_shard_cost(hero):
			app._add_action_button("碎片召喚", Vector2(1426, 586), func() -> void:
				_unlock_hero_with_shards(hero_id)
			, Vector2(132, 44))
	else:
		app._add_action_button("詳情", Vector2(1280, 586), func() -> void:
			_show_hero_detail_info_modal(hero_id)
		, Vector2(132, 44), UI_COMMON_BTN_WHITE)
		app._add_action_button("設主看板", Vector2(1426, 586), func() -> void:
			_set_hero_as_wallpaper(hero_id)
		, Vector2(132, 44))
		app._add_action_button("設Gal", Vector2(1426, 636), func() -> void:
			_set_hero_as_gal(hero_id)
		, Vector2(92, 44))
		app._add_action_button("收藏", Vector2(1524, 636), func() -> void:
			_toggle_favorite_hero(hero_id)
		, Vector2(84, 44))
	if copies <= 0:
		app._add_action_button("詳情", Vector2(1280, 586), func() -> void:
			_show_hero_detail_info_modal(hero_id)
		, Vector2(132, 44), UI_COMMON_BTN_WHITE)
	app._add_action_button("返回幻靈", Vector2(1280, 636), _show_gallery, Vector2(132, 44))


func _draw_hero_detail_background() -> void:
	app._draw_image(UI_HERO_BG_MAIN, HERO_MAIN_BG_POS, HERO_MAIN_BG_SIZE, true, Color(1, 1, 1, 0.90))
	app._draw_image(UI_HERO_BG_STAR, HERO_MAIN_BG_POS, HERO_MAIN_BG_SIZE, true, Color(1, 1, 1, 0.24))
	app._draw_image(UI_HERO_BG_DETAIL, HERO_MAIN_BG_POS, HERO_MAIN_BG_SIZE, true, Color(1, 1, 1, 0.34))
	app._draw_image(UI_HERO_SELECTOR_BG, HERO_SELECTOR_PANEL_POS, HERO_SELECTOR_PANEL_SIZE, true, Color(1, 1, 1, 0.88))
	app._draw_image(UI_HERO_SELECTOR_BG, HERO_SELECTOR_PANEL_POS, HERO_SELECTOR_PANEL_SIZE, true, Color(1, 1, 1, 0.36))
	app._draw_image(UI_HERO_SELECTOR_TOP, HERO_SELECTOR_PANEL_POS + Vector2(-1, 1), Vector2(102, 49), false, Color(1, 1, 1, 0.96))
	app._draw_image(UI_HERO_SORT_BTN, HERO_SELECTOR_SORT_POS, Vector2(54, 54), false, Color(1, 1, 1, 0.92))
	app._add_hit_button(HERO_SELECTOR_SORT_POS - Vector2(8, 8), Vector2(70, 70), func() -> void:
		gallery_sort_open = not gallery_sort_open
		_show_hero_detail(int(app.save.get("hero_detail_last_id", DEFAULT_HERO_ID)))
	)


func _draw_hero_selector_strip(selected_hero_id: int) -> void:
	var y := 132.0
	for hero in _hero_selector_heroes(selected_hero_id):
		var hero_id := int(hero.get("id", 0))
		var selected = hero_id == selected_hero_id
		_draw_hero_selector_grid(hero, Vector2(51, y), selected)
		y += 78.0


func _hero_selector_heroes(selected_hero_id: int) -> Array:
	var list: Array = _detail_cycle_heroes(selected_hero_id)
	if list.is_empty():
		return []
	var selected_index := _hero_index_in_list(list, selected_hero_id)
	if selected_index < 0:
		selected_index = 0
	var visible_count: int = mini(7, list.size())
	var start_index: int = clampi(selected_index - int(visible_count / 2), 0, maxi(0, list.size() - visible_count))
	return list.slice(start_index, start_index + visible_count)


func _draw_hero_selector_grid(hero: Dictionary, pos: Vector2, selected: bool) -> void:
	var hero_id := int(hero.get("id", 0))
	var rarity := int(hero.get("rarity", 1))
	var key := str(hero_id)
	var level := int(app.save.get("hero_levels", {}).get(key, 1))
	var can_up := int(app.save.get("shards", {}).get(key, 0)) >= _hero_unlock_shard_cost(hero) or int(app.save.get("owned", {}).get(key, 0)) > 0
	if selected:
		app._draw_image(UI_HERO_HIGHLIGHT, pos - Vector2(15, 15), Vector2(100, 100), false, Color(1, 1, 1, 0.86))
	app._draw_hero_round_thumb(hero, pos, Vector2(70, 70), Color(1, 1, 1, 1))
	app._draw_image(UI_COMMON_HERO_HEAD_FRAME, pos, Vector2(70, 70), false, Color(1, 1, 1, 0.96))
	_draw_hero_select_star_bar(rarity, pos + Vector2(0, 63))
	app._draw_image(UI_COMMON_LEVEL_BADGE, pos + Vector2(25, 25), Vector2(28, 28), false, Color(1, 1, 1, 0.92))
	var level_label: Label = app._label(str(level), 13, HORIZONTAL_ALIGNMENT_CENTER)
	level_label.position = pos + Vector2(28, 25)
	level_label.size = Vector2(23, 28)
	level_label.modulate = Color(1.0, 0.96, 0.76)
	app._view_container().add_child(level_label)
	if can_up:
		app._draw_red_dot(pos + Vector2(60, -6))

	var button := Button.new()
	button.text = ""
	button.flat = true
	button.position = pos - Vector2(6, 6)
	button.size = Vector2(82, 82)
	button.focus_mode = Control.FOCUS_NONE
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.pressed.connect(func() -> void:
		_show_hero_detail(hero_id)
	)
	app._view_container().add_child(button)


func _draw_hero_select_star_bar(rarity: int, pos: Vector2) -> void:
	app._draw_image(UI_COMMON_HERO_STAR_BAR, pos, Vector2(70, 14), false, Color(1, 1, 1, 0.78))
	var count: int = clamp(rarity, 1, 5)
	var start_x := pos.x + (70.0 - float(count) * 14.0) * 0.5
	for i in range(count):
		app._draw_image(UI_HERO_STAR_SMALL, Vector2(start_x + i * 14.0, pos.y), Vector2(14, 14), false, Color(1, 1, 1, 0.95))


func _draw_hero_main_function_tabs(hero: Dictionary) -> void:
	var hero_id := int(hero.get("id", 0))
	app._view_container().add_child(app._panel(HERO_LEFT_FUNC_TAB_POS, HERO_LEFT_FUNC_TAB_SIZE, Color(0.018, 0.015, 0.024, 0.30)))
	var tabs := [
		{"key": "core", "text": "核心"},
		{"key": "attrs", "text": "屬性"},
		{"key": "equip", "text": "靈裝"},
		{"key": "slug", "text": "源神"},
		{"key": "weapon", "text": "神具"},
		{"key": "upstage", "text": "升階"},
		{"key": "detail", "text": "詳情"},
		{"key": "back", "text": "返回"},
	]
	for index in range(tabs.size()):
		var tab: Dictionary = tabs[index]
		var tab_key := str(tab.get("key", "core"))
		var tab_pos := HERO_LEFT_FUNC_TAB_POS + Vector2(0, index * HERO_LEFT_FUNC_TAB_ITEM_H)
		var selected := tab_key == hero_detail_tab
		if selected:
			app._draw_image(UI_COMMON_TAB_HIGHLIGHT, tab_pos + Vector2(-2, 0), Vector2(165, 62), false, Color(1, 1, 1, 0.92))
		else:
			app._view_container().add_child(app._panel(tab_pos + Vector2(8, 8), Vector2(142, 46), Color(0.052, 0.044, 0.062, 0.56)))
		var dot_color := Color(1.0, 0.74, 0.30, 0.86) if selected else Color(0.78, 0.66, 0.56, 0.72)
		app._view_container().add_child(app._panel(tab_pos + Vector2(28, 19), Vector2(8, 26), dot_color))
		var label: Label = app._label(str(tab.get("text", "")), 19, HORIZONTAL_ALIGNMENT_CENTER)
		label.position = tab_pos + Vector2(48, 15)
		label.size = Vector2(92, 30)
		label.modulate = Color(1.0, 0.92, 0.74) if selected else Color(0.86, 0.82, 0.78)
		app._view_container().add_child(label)
		var target_tab := tab_key
		app._add_hit_button(tab_pos + Vector2(4, 3), Vector2(153, 58), func() -> void:
			if target_tab == "detail":
				_show_hero_detail_info_modal(hero_id)
				return
			if target_tab == "back":
				_show_gallery()
				return
			hero_detail_tab = target_tab
			_show_hero_detail(hero_id)
		)


func _draw_hero_main_core_panel(hero: Dictionary, pos: Vector2) -> void:
	app._view_container().add_child(app._panel(pos, HERO_CORE_PANEL_SIZE, Color(0.020, 0.017, 0.026, 0.22)))
	match hero_detail_tab:
		"attrs":
			_draw_hero_main_attrs_content(hero, pos)
		"skills":
			_draw_hero_main_skills_content(hero, pos)
		"equip":
			_draw_hero_main_equip_content(hero, pos)
		"slug":
			_draw_hero_main_slug_content(hero, pos)
		"weapon":
			_draw_hero_main_weapon_content(hero, pos)
		"upstage":
			_draw_hero_main_upstage_content(hero, pos)
		"bond":
			_draw_hero_main_bond_content(hero, pos)
		_:
			_draw_hero_main_core_content(hero, pos)


func _draw_hero_main_panel_header(text: String, pos: Vector2) -> void:
	_draw_hero_section_header(text, pos + Vector2(82, 22), Vector2(390, 34))


func _draw_hero_main_core_content(hero: Dictionary, pos: Vector2) -> void:
	var image_pos := pos + (HERO_CORE_PANEL_SIZE - Vector2(250, 250)) * 0.5
	app._draw_image(UI_COMMON_WAIT_BG, image_pos, Vector2(250, 250), false, Color(1, 1, 1, 0.82))
	var label: Label = app._label("敬请期待", 30, HORIZONTAL_ALIGNMENT_CENTER)
	label.position = image_pos + Vector2(45, 110)
	label.size = Vector2(160, 30)
	label.modulate = Color(0.62, 0.55, 0.47)
	app._view_container().add_child(label)


func _draw_hero_main_attrs_content(hero: Dictionary, pos: Vector2) -> void:
	var hero_id := int(hero.get("id", 0))
	var attrs := _hero_attrs(hero)
	var level := int(app.save.get("hero_levels", {}).get(str(hero_id), 1))
	var rarity := int(hero.get("rarity", 1))

	var god: Label = app._label(str(hero.get("title", "幻靈之力")), 22)
	god.position = pos + Vector2(82, 61)
	god.size = Vector2(160, 32)
	god.modulate = Color(0.92, 0.82, 0.66)
	app._view_container().add_child(god)
	var name: Label = app._label(str(hero.get("name", "角色")), 30)
	name.position = pos + Vector2(82, 82)
	name.size = Vector2(230, 58)
	name.modulate = Color(1.0, 0.92, 0.74)
	app._view_container().add_child(name)
	app._draw_image(UI_HERO_ATTR_RARE, pos + Vector2(437, 69), Vector2(52, 44), false, Color(1, 1, 1, 0.90))
	var rare_label: Label = app._label("R%d" % rarity, 16, HORIZONTAL_ALIGNMENT_CENTER)
	rare_label.position = pos + Vector2(437, 78)
	rare_label.size = Vector2(52, 24)
	rare_label.modulate = Color(1.0, 0.87, 0.54)
	app._view_container().add_child(rare_label)

	app._draw_image(UI_HERO_ATTR_LINE, pos + Vector2(82, 142), Vector2(390, 10), false, Color(1, 1, 1, 0.88))
	app._draw_image(UI_HERO_ATTR_INFO_BG, pos + Vector2(82, 170), Vector2(390, 40), true, Color(1, 1, 1, 0.92))
	for i in range(5):
		app._draw_image(UI_HERO_STAR_SMALL, pos + Vector2(93 + i * 30.0, 168), Vector2(44, 44), false, Color(1, 1, 1, 0.96 if i < clamp(rarity, 1, 5) else 0.26))
	_draw_hero_main_info_chip(_hero_occupation_label(hero), pos + Vector2(280, 176), Vector2(92, 28))
	_draw_hero_main_info_chip(_hero_camp_label(hero), pos + Vector2(383, 176), Vector2(74, 28))

	app._draw_image(UI_HERO_ATTR_LINE, pos + Vector2(82, 264), Vector2(390, 10), false, Color(1, 1, 1, 0.76))
	_draw_hero_main_big_value("等级", "Lv.%d" % level, pos + Vector2(82, 292), Vector2(208, 70), Color(0.45, 0.66, 0.95, 0.82))
	_draw_hero_main_big_value("战力", str(_hero_power(hero)), pos + Vector2(264, 292), Vector2(208, 70), Color(0.95, 0.65, 0.36, 0.82))

	var attr_panel := pos + Vector2(82, 369)
	app._draw_image(UI_HERO_ATTR_ROW_BG, attr_panel + Vector2(0, 5), Vector2(390, 30), false, Color(1, 1, 1, 0.78))
	app._draw_image(UI_HERO_ATTR_ROW_BG, attr_panel + Vector2(0, 45), Vector2(390, 30), false, Color(1, 1, 1, 0.78))
	_draw_hero_main_attr_item(UI_HERO_ATTR_ATTACK, "攻击", str(attrs.get("攻擊", "")), attr_panel + Vector2(1, 20))
	_draw_hero_main_attr_item(UI_HERO_ATTR_HP, "生命", str(attrs.get("生命", "")), attr_panel + Vector2(200, 20))
	_draw_hero_main_attr_item(UI_HERO_ATTR_DEFENSE, "防御", str(attrs.get("防禦", "")), attr_panel + Vector2(1, 60))
	_draw_hero_main_attr_item(UI_HERO_ATTR_SPEED, "速度", str(attrs.get("速度", "")), attr_panel + Vector2(200, 60))

	app._draw_image(UI_HERO_ATTR_DETAIL_BTN, pos + Vector2(82, 452), Vector2(390, 30), false, Color(1, 1, 1, 0.90))
	var detail_label: Label = app._label("详情属性", 18, HORIZONTAL_ALIGNMENT_CENTER)
	detail_label.position = pos + Vector2(82, 452)
	detail_label.size = Vector2(390, 30)
	detail_label.modulate = Color(0.98, 0.90, 0.74)
	app._view_container().add_child(detail_label)
	app._add_hit_button(pos + Vector2(82, 452), Vector2(390, 30), func() -> void:
		_show_hero_detail_info_modal(hero_id)
	)

	app._draw_image(UI_HERO_ATTR_INFO_BG, pos + Vector2(82, 527), Vector2(390, 70), true, Color(1, 1, 1, 0.90))
	var skill_paths: Array = hero.get("skillResources", [])
	for i in range(4):
		var icon_pos := pos + Vector2(96 + i * 93.0, 538)
		app._draw_image(UI_HERO_SKILL_BG, icon_pos, Vector2(84, 84), false, Color(1, 1, 1, 0.82))
		if i < skill_paths.size():
			app._draw_image(app._godot_resource_path(str(skill_paths[i])), icon_pos + Vector2(10, 10), Vector2(64, 64), false, Color(1, 1, 1, 0.95))
		app._draw_image(UI_HERO_SKILL_BTN, icon_pos, Vector2(84, 84), true, Color(1, 1, 1, 0.42))
		var skill_index := i
		app._add_hit_button(icon_pos, Vector2(84, 84), func() -> void:
			app.save["hero_selected_skill"] = skill_index
			hero_detail_tab = "skills"
			_show_hero_detail(hero_id)
		)

	app._add_action_button("培養 +1", pos + Vector2(260, 646), func() -> void:
		_train_hero(hero_id)
	, Vector2(132, 42), UI_COMMON_BTN_GOLD)
	app._add_action_button("升星", pos + Vector2(402, 646), func() -> void:
		_promote_hero(hero_id)
	, Vector2(132, 42), UI_COMMON_BTN_WHITE)


func _draw_hero_main_info_chip(text: String, pos: Vector2, size: Vector2) -> void:
	app._view_container().add_child(app._panel(pos, size, Color(0.03, 0.025, 0.035, 0.36)))
	var label: Label = app._label(text, 18, HORIZONTAL_ALIGNMENT_CENTER)
	label.position = pos
	label.size = size
	label.modulate = Color(0.94, 0.88, 0.76)
	app._view_container().add_child(label)


func _draw_hero_main_big_value(caption: String, value: String, pos: Vector2, size: Vector2, tint: Color) -> void:
	app._view_container().add_child(app._panel(pos, size, Color(tint.r, tint.g, tint.b, 0.12)))
	var caption_label: Label = app._label(caption, 20)
	caption_label.position = pos + Vector2(15, 5)
	caption_label.size = Vector2(70, 29)
	caption_label.modulate = Color(0.90, 0.84, 0.76)
	app._view_container().add_child(caption_label)
	var value_label: Label = app._label(value, 26)
	value_label.position = pos + Vector2(15, 28)
	value_label.size = Vector2(size.x - 26, 38)
	value_label.modulate = Color(1.0, 0.92, 0.70)
	app._view_container().add_child(value_label)


func _draw_hero_main_attr_item(icon_path: String, label_text: String, value_text: String, pos: Vector2) -> void:
	app._draw_image(icon_path, pos, Vector2(30, 30), false, Color(1, 1, 1, 0.90))
	var label: Label = app._label(label_text, 18)
	label.position = pos + Vector2(35, 0)
	label.size = Vector2(52, 30)
	label.modulate = Color(0.92, 0.86, 0.78)
	app._view_container().add_child(label)
	var value: Label = app._label(value_text, 22, HORIZONTAL_ALIGNMENT_RIGHT)
	value.position = pos + Vector2(84, 0)
	value.size = Vector2(90, 30)
	value.modulate = Color(1.0, 0.88, 0.58)
	app._view_container().add_child(value)


func _draw_hero_panel_title(text: String, pos: Vector2) -> void:
	var label: Label = app._label(text, 20)
	label.position = pos
	label.size = Vector2(210, 29)
	label.modulate = Color(0.96, 0.88, 0.72)
	app._view_container().add_child(label)
	app._draw_image(UI_HERO_ATTR_LINE, pos + Vector2(0, 35), Vector2(390, 10), false, Color(1, 1, 1, 0.78))


func _draw_hero_panel_attr_row(label_text: String, value_text: String, pos: Vector2, icon_path := "") -> void:
	app._draw_image(UI_HERO_ATTR_ROW_BG, pos, Vector2(390, 30), true, Color(1, 1, 1, 0.76))
	if not icon_path.is_empty():
		app._draw_image(icon_path, pos + Vector2(3, 0), Vector2(30, 30), false, Color(1, 1, 1, 0.88))
	var label_x := 38.0 if not icon_path.is_empty() else 20.0
	var label: Label = app._label(label_text, 18)
	label.position = pos + Vector2(label_x, 0)
	label.size = Vector2(190, 30)
	label.modulate = Color(0.92, 0.86, 0.78)
	app._view_container().add_child(label)
	var value: Label = app._label(value_text, 22, HORIZONTAL_ALIGNMENT_RIGHT)
	value.position = pos + Vector2(205, 0)
	value.size = Vector2(172, 30)
	value.modulate = Color(1.0, 0.88, 0.58)
	app._view_container().add_child(value)


func _draw_hero_equip_stage(hero_id: int, center: Vector2) -> void:
	app._draw_image(UI_HERO_EQUIP_BG, center - Vector2(340, 310), Vector2(680, 620), true, Color(1, 1, 1, 0.80))
	app._draw_image(UI_HERO_EQUIP_SLOT_FX_A, center - Vector2(105, 105), Vector2(210, 210), false, Color(1, 1, 1, 0.36))
	app._draw_image(UI_HERO_EQUIP_SLOT_FX_A, center - Vector2(82, 82), Vector2(164, 164), false, Color(1, 1, 1, 0.28))
	app._draw_image(UI_HERO_EQUIP_SELECT, center - Vector2(110, 110), Vector2(220, 220), false, Color(1, 1, 1, 0.82))
	var main_level := _hero_equipment_level(hero_id, "equip", 1)
	_draw_hero_equip_slot(hero_id, 1, center + Vector2(-204, -102), Vector2(120, 120), main_level)
	_draw_hero_equip_slot(hero_id, 2, center + Vector2(-113, 102), Vector2(120, 120), _hero_equipment_level(hero_id, "equip", 2))
	_draw_hero_equip_slot(hero_id, 3, center + Vector2(117, 102), Vector2(120, 120), _hero_equipment_level(hero_id, "equip", 3))
	_draw_hero_equip_slot(hero_id, 4, center + Vector2(208, -102), Vector2(90, 90), _hero_equipment_level(hero_id, "equip", 4))
	var title: Label = app._label("主灵装", 24, HORIZONTAL_ALIGNMENT_CENTER)
	title.position = center + Vector2(-90, 120)
	title.size = Vector2(180, 34)
	title.modulate = Color(1.0, 0.91, 0.66)
	app._view_container().add_child(title)


func _draw_hero_equip_slot(hero_id: int, slot: int, center: Vector2, size: Vector2, level: int) -> void:
	var pos := center - size * 0.5
	app._draw_image(UI_COMMON_SKILL_FRAME, pos, size, false, Color(1.0, 0.86, 0.35, 0.82 if level > 0 else 0.40))
	app._draw_image(UI_HERO_EQUIP_SELECT, center - Vector2(110, 110), Vector2(220, 220), false, Color(1, 1, 1, 0.28 if level > 0 else 0.10))
	var symbol: Label = app._label("装%d" % slot, 22, HORIZONTAL_ALIGNMENT_CENTER)
	symbol.position = pos + Vector2(10, size.y * 0.28)
	symbol.size = Vector2(size.x - 20, 32)
	symbol.modulate = Color(1.0, 0.94, 0.70)
	app._view_container().add_child(symbol)
	var lv: Label = app._label("LV.%d" % level, 18, HORIZONTAL_ALIGNMENT_CENTER)
	lv.position = center + Vector2(-110, -160)
	lv.size = Vector2(220, 32)
	lv.modulate = Color(0.98, 0.88, 0.70)
	app._view_container().add_child(lv)
	app._draw_image(UI_HERO_EQUIP_STRENGTH, center + Vector2(-73, -192), Vector2(146, 32), false, Color(1, 1, 1, 0.84 if level > 0 else 0.42))
	app._draw_image(UI_HERO_EQUIP_STRENGTH_ICON, center + Vector2(-40, -194), Vector2(36, 36), false, Color(1, 1, 1, 0.84 if level > 0 else 0.42))
	var strength: Label = app._label("+%d" % level, 20)
	strength.position = center + Vector2(-4, -192)
	strength.size = Vector2(80, 30)
	strength.modulate = Color(1.0, 0.86, 0.52)
	app._view_container().add_child(strength)
	app._add_hit_button(pos, size, func() -> void:
		_upgrade_hero_equipment(hero_id, "equip", slot)
	)


func _draw_hero_main_skills_content(hero: Dictionary, pos: Vector2) -> void:
	var hero_id := int(hero.get("id", 0))
	var skill_paths: Array = hero.get("skillResources", [])
	var selected_skill: int = clampi(int(app.save.get("hero_selected_skill", 0)), 0, 3)
	_draw_hero_main_panel_header("技能", pos)
	for i in range(4):
		var icon_pos := pos + Vector2(52 + i * 92.0, 112)
		if i == selected_skill:
			app._view_container().add_child(app._panel(icon_pos - Vector2(6, 6), Vector2(78, 100), Color(0.86, 0.60, 0.24, 0.24)))
		app._draw_image(UI_COMMON_SKILL_FRAME, icon_pos, Vector2(66, 66), false, Color(1, 1, 1, 0.84))
		if i < skill_paths.size():
			app._draw_image(app._godot_resource_path(str(skill_paths[i])), icon_pos + Vector2(7, 7), Vector2(52, 52), false)
		var skill_level := _hero_skill_level(hero_id, i)
		var skill_label: Label = app._label("Lv.%d" % skill_level, 13, HORIZONTAL_ALIGNMENT_CENTER)
		skill_label.position = icon_pos + Vector2(0, 70)
		skill_label.size = Vector2(66, 20)
		app._view_container().add_child(skill_label)
		var skill_index := i
		app._add_hit_button(icon_pos, Vector2(66, 90), func() -> void:
			_select_hero_skill(hero_id, skill_index)
		)
	app._add_action_button("升級技能%d" % (selected_skill + 1), pos + Vector2(244, 520), func() -> void:
		_upgrade_hero_skill(hero_id, selected_skill)
	, Vector2(150, 42), UI_COMMON_BTN_GOLD)
	app._add_action_button("查看演示", pos + Vector2(244, 572), func() -> void:
		app.save["hero_last_skill_preview"] = "%s:%d" % [hero_id, selected_skill]
		_set_hero_notice("已標記技能 %d 演示" % (selected_skill + 1))
		app._persist()
		_show_hero_detail(hero_id)
	, Vector2(150, 42), UI_COMMON_BTN_WHITE)


func _draw_hero_main_equip_content(hero: Dictionary, pos: Vector2) -> void:
	var hero_id := int(hero.get("id", 0))
	var stage_center := HERO_DETAIL_STAGE_POS + Vector2(530, 375)
	_draw_hero_equip_stage(hero_id, stage_center)
	_draw_hero_panel_title("装备属性", pos + Vector2(82, 41))
	var equip_total := 0
	for slot in range(1, 5):
		equip_total += _hero_equipment_level(hero_id, "equip", slot)
	_draw_hero_panel_attr_row("攻击", "+%d" % (420 + equip_total * 26), pos + Vector2(82, 95))
	_draw_hero_panel_attr_row("生命", "+%d" % (2600 + equip_total * 180), pos + Vector2(82, 135))
	_draw_hero_panel_title("灵装强化属性", pos + Vector2(82, 181))
	_draw_hero_panel_attr_row("攻击", "+%d" % (equip_total * 18), pos + Vector2(82, 235))
	_draw_hero_panel_attr_row("防御", "+%d" % (equip_total * 11), pos + Vector2(82, 275))
	_draw_hero_panel_title("附加属性", pos + Vector2(82, 315))
	_draw_hero_panel_attr_row("暴击", "+%d%%" % (3 + equip_total), pos + Vector2(82, 369))
	_draw_hero_panel_attr_row("命中", "+%d%%" % (5 + equip_total), pos + Vector2(82, 409))
	_draw_hero_panel_attr_row("套装", "4件共鸣 Lv.%d" % equip_total, pos + Vector2(82, 449))
	app._add_action_button("一键装备", pos + Vector2(260, 646), func() -> void:
		_upgrade_all_hero_equipment(hero_id)
	, Vector2(132, 42), UI_HERO_BIG_BTN_C)
	app._add_action_button("快速强化", pos + Vector2(402, 646), func() -> void:
		_upgrade_all_hero_equipment(hero_id)
	, Vector2(132, 42), UI_HERO_BIG_BTN_A)


func _draw_hero_main_slug_content(hero: Dictionary, pos: Vector2) -> void:
	var hero_id := int(hero.get("id", 0))
	var stage_origin := HERO_DETAIL_STAGE_POS + Vector2(0, 0)
	_draw_hero_slug_stage(hero_id, stage_origin)
	_draw_hero_panel_title("源神升级加成", pos + Vector2(82, 41))
	var total := _hero_slug_total(hero_id)
	var attrs := _hero_slug_attrs(hero_id)
	for index in range(attrs.size()):
		var entry: Array = attrs[index]
		_draw_hero_panel_attr_row(str(entry[0]), str(entry[1]), pos + Vector2(82, 76 + index * 40.0))
	var note: Label = app._label("（升级源神即可获得全局阵容加成）", 18, HORIZONTAL_ALIGNMENT_CENTER)
	note.position = pos + Vector2(66, 245)
	note.size = Vector2(430, 29)
	note.modulate = Color(0.90, 0.82, 0.70)
	app._view_container().add_child(note)
	_draw_hero_slug_tabs(hero_id, pos + Vector2(146, 286))
	app._draw_image(UI_HERO_SLUG_TAB_LINE, pos + Vector2(82, 386), Vector2(390, 6), false, Color(1, 1, 1, 0.78))
	var skill_text := "%s\n%s\n%s" % [
		_hero_slug_name(hero_id, 1),
		"源神总等级 Lv.%d，提升攻击、生命、防御与速度。" % total,
		"当前选择的源神会同步到主战位，后续可接真实源神技能表。"
	]
	var skill: Label = app._label(skill_text, 18)
	skill.position = pos + Vector2(82, 408)
	skill.size = Vector2(390, 132)
	skill.modulate = Color(0.92, 0.86, 0.78)
	app._view_container().add_child(skill)
	_draw_hero_slug_top_buttons(pos)
	app._add_action_button("一键装配", pos + Vector2(260, 646), func() -> void:
		_upgrade_all_hero_slugs(hero_id)
	, Vector2(132, 42), UI_HERO_BIG_BTN_C)
	app._add_action_button("替换", pos + Vector2(402, 646), func() -> void:
		_upgrade_hero_slug(hero_id, 1)
	, Vector2(132, 42), UI_HERO_BIG_BTN_A)


func _draw_hero_main_weapon_content(hero: Dictionary, pos: Vector2) -> void:
	var hero_id := int(hero.get("id", 0))
	var level := _hero_weapon_level(hero_id)
	if level <= 0:
		_draw_hero_weapon_empty(hero, pos)
		return
	_draw_hero_weapon_content(hero, pos, level)


func _draw_hero_weapon_empty(hero: Dictionary, pos: Vector2) -> void:
	var hero_id := int(hero.get("id", 0))
	var title: Label = app._label("未装备", 30)
	title.position = pos + Vector2(82, 37)
	title.size = Vector2(160, 43)
	title.modulate = Color(0.96, 0.88, 0.72)
	app._view_container().add_child(title)
	app._draw_image(UI_COMMON_WAIT_BG, pos + Vector2(151, 250), Vector2(250, 250), false, Color(1, 1, 1, 0.78))
	app._draw_image(UI_HERO_WEAPON_EMPTY_ICON, pos + Vector2(196, 295), Vector2(160, 160), false, Color(1, 1, 1, 0.86))
	var empty: Label = app._label("未装备神具", 22, HORIZONTAL_ALIGNMENT_CENTER)
	empty.position = pos + Vector2(206, 360)
	empty.size = Vector2(140, 32)
	empty.modulate = Color(0.70, 0.64, 0.58)
	app._view_container().add_child(empty)
	app._add_action_button("装备神具", pos + Vector2(260, 646), func() -> void:
		_upgrade_hero_weapon(hero_id)
	, Vector2(132, 42), UI_HERO_BIG_BTN_GOLD)


func _draw_hero_weapon_content(hero: Dictionary, pos: Vector2, level: int) -> void:
	var hero_id := int(hero.get("id", 0))
	var name := "%s专属神具" % str(hero.get("name", "幻靈"))
	var title: Label = app._label(name, 30)
	title.position = pos + Vector2(82, 37)
	title.size = Vector2(300, 43)
	title.modulate = Color(1.0, 0.92, 0.74)
	app._view_container().add_child(title)
	var lv: Label = app._label("Lv%d" % level, 28, HORIZONTAL_ALIGNMENT_RIGHT)
	lv.position = pos + Vector2(360, 48)
	lv.size = Vector2(112, 41)
	lv.modulate = Color(1.0, 0.84, 0.50)
	app._view_container().add_child(lv)
	app._draw_image(UI_COMMON_SKILL_FRAME, pos + Vector2(176, 108), Vector2(200, 200), false, Color(1.0, 0.86, 0.36, 0.90))
	app._draw_image(UI_HERO_WEAPON_EMPTY_ICON, pos + Vector2(196, 128), Vector2(160, 160), false, Color(1, 1, 1, 0.94))
	_draw_hero_panel_title("归属", pos + Vector2(82, 318))
	_draw_hero_panel_attr_row("适用幻灵", str(hero.get("name", "角色")), pos + Vector2(82, 372))
	_draw_hero_panel_attr_row("攻击", "+%d" % (580 + level * 42), pos + Vector2(82, 412), UI_HERO_ATTR_ATTACK)
	_draw_hero_panel_attr_row("生命", "+%d" % (3600 + level * 260), pos + Vector2(82, 452), UI_HERO_ATTR_HP)
	var add_info := "神具锻造 Lv.%d\n释放技能后提升自身伤害与命中，等级越高加成越强。" % level
	var info: Label = app._label(add_info, 18)
	info.position = pos + Vector2(82, 508)
	info.size = Vector2(390, 76)
	info.modulate = Color(0.92, 0.86, 0.78)
	app._view_container().add_child(info)
	app._add_action_button("替换", pos + Vector2(260, 646), func() -> void:
		_set_hero_notice("神具替换入口已保留")
		app._persist()
		_show_hero_detail(hero_id)
	, Vector2(132, 42), UI_HERO_BIG_BTN_B)
	app._add_action_button("锻造", pos + Vector2(402, 646), func() -> void:
		_upgrade_hero_weapon(hero_id)
	, Vector2(132, 42), UI_HERO_BIG_BTN_A)


func _draw_hero_main_upstage_content(hero: Dictionary, pos: Vector2) -> void:
	var hero_id := int(hero.get("id", 0))
	var step := _hero_upstage_step(hero_id)
	_draw_hero_upstage_map(hero_id, HERO_DETAIL_STAGE_POS + Vector2(530, 375), step)
	var stage_name := _hero_stage_sign_name(hero_id)
	var title: Label = app._label(stage_name, 30)
	title.position = pos + Vector2(82, 109)
	title.size = Vector2(210, 50)
	title.modulate = Color(1.0, 0.92, 0.74)
	app._view_container().add_child(title)
	var stage_label: Label = app._label("%d星%d阶" % [int(step / 2) + 1, step + 1], 24, HORIZONTAL_ALIGNMENT_RIGHT)
	stage_label.position = pos + Vector2(354, 120)
	stage_label.size = Vector2(118, 50)
	stage_label.modulate = Color(1.0, 0.84, 0.50)
	app._view_container().add_child(stage_label)
	app._draw_image(UI_HERO_ATTR_LINE, pos + Vector2(82, 174), Vector2(390, 10), false, Color(1, 1, 1, 0.78))
	var attrs := _hero_attrs(hero)
	_draw_hero_stage_compare_row(UI_HERO_ATTR_ATTACK, "攻击", int(attrs.get("攻擊", 0)), 120 + step * 20, pos + Vector2(82, 194))
	_draw_hero_stage_compare_row(UI_HERO_ATTR_HP, "生命", int(attrs.get("生命", 0)), 620 + step * 110, pos + Vector2(82, 234))
	if step >= 6:
		app._draw_image(UI_HERO_ATTR_ROW_BG, pos + Vector2(82, 563), Vector2(390, 30), true, Color(1, 1, 1, 0.76))
		var max_tip: Label = app._label("已达到最大等级", 22, HORIZONTAL_ALIGNMENT_CENTER)
		max_tip.position = pos + Vector2(82, 563)
		max_tip.size = Vector2(390, 30)
		max_tip.modulate = Color(1.0, 0.88, 0.64)
		app._view_container().add_child(max_tip)
	else:
		app._draw_image(UI_HERO_ATTR_LINE, pos + Vector2(82, 474), Vector2(390, 10), false, Color(1, 1, 1, 0.78))
		var cost_title: Label = app._label("消耗材料", 20, HORIZONTAL_ALIGNMENT_CENTER)
		cost_title.position = pos + Vector2(197, 474)
		cost_title.size = Vector2(160, 30)
		cost_title.modulate = Color(0.96, 0.88, 0.72)
		app._view_container().add_child(cost_title)
		app._draw_image(UI_COMMON_ITEM_FRAME, pos + Vector2(227, 500), Vector2(100, 100), false, Color(1, 1, 1, 0.86))
		app._draw_image(UI_ITEM_DRAW_02, pos + Vector2(238, 511), Vector2(78, 78), false, Color(1, 1, 1, 0.94))
		var cost: Label = app._label("%d/%d" % [int(app.save.get("gems", 0)), 600 + step * 300], 18, HORIZONTAL_ALIGNMENT_CENTER)
		cost.position = pos + Vector2(148, 594)
		cost.size = Vector2(260, 29)
		cost.modulate = Color(0.94, 0.86, 0.74)
		app._view_container().add_child(cost)
		app._add_action_button("点亮星格", pos + Vector2(346, 646), func() -> void:
			_upgrade_hero_upstage(hero_id)
		, Vector2(160, 42), UI_HERO_BIG_BTN_GOLD)


func _draw_hero_upstage_map(hero_id: int, center: Vector2, step: int) -> void:
	app._draw_image(UI_HERO_STAGE_BG, center - Vector2(375, 375), Vector2(750, 750), true, Color(1, 1, 1, 0.72))
	var offsets := [
		Vector2(-248, 33),
		Vector2(-63, -51),
		Vector2(-39, -216),
		Vector2(138, -86),
		Vector2(234, 44),
		Vector2(199, 205),
	]
	for i in range(offsets.size() - 1):
		var a: Vector2 = center + offsets[i]
		var b: Vector2 = center + offsets[i + 1]
		var line := _line_rect_between(a, b)
		app._draw_image(UI_HERO_STAGE_LINE, Vector2(line.get("position", Vector2.ZERO)), Vector2(line.get("size", Vector2.ZERO)), true, Color(1, 1, 1, 0.70 if i < step else 0.28))
	for i in range(offsets.size()):
		var node_center: Vector2 = center + offsets[i]
		app._draw_image(UI_HERO_STAGE_STEP_AURA, node_center - Vector2(62, 62), Vector2(125, 125), false, Color(1, 1, 1, 0.44 if i < step else 0.16))
		app._draw_image(UI_HERO_STAGE_STEP_ON if i < step else UI_HERO_STAGE_STEP_OFF, node_center - Vector2(62, 62), Vector2(125, 125), false, Color(1, 1, 1, 0.94 if i < step else 0.58))
		var label: Label = app._label(str(i + 1), 24, HORIZONTAL_ALIGNMENT_CENTER)
		label.position = node_center - Vector2(24, 18)
		label.size = Vector2(48, 36)
		label.modulate = Color(1.0, 0.94, 0.72) if i < step else Color(0.70, 0.68, 0.70)
		app._view_container().add_child(label)


func _draw_hero_stage_compare_row(icon_path: String, name: String, old_value: int, delta: int, pos: Vector2) -> void:
	app._draw_image(UI_HERO_ATTR_ROW_BG, pos, Vector2(390, 30), true, Color(1, 1, 1, 0.78))
	app._draw_image(icon_path, pos + Vector2(3, 0), Vector2(30, 30), false, Color(1, 1, 1, 0.90))
	var label: Label = app._label(name, 18)
	label.position = pos + Vector2(32, 0)
	label.size = Vector2(100, 26)
	label.modulate = Color(0.92, 0.86, 0.78)
	app._view_container().add_child(label)
	var old_label: Label = app._label(str(old_value), 20, HORIZONTAL_ALIGNMENT_RIGHT)
	old_label.position = pos + Vector2(145, 0)
	old_label.size = Vector2(90, 30)
	old_label.modulate = Color(0.90, 0.86, 0.80)
	app._view_container().add_child(old_label)
	var next_label: Label = app._label(str(old_value + delta), 20, HORIZONTAL_ALIGNMENT_RIGHT)
	next_label.position = pos + Vector2(284, 0)
	next_label.size = Vector2(93, 30)
	next_label.modulate = Color(1.0, 0.88, 0.58)
	app._view_container().add_child(next_label)
	var arrow: Label = app._label(">", 18, HORIZONTAL_ALIGNMENT_CENTER)
	arrow.position = pos + Vector2(247, 0)
	arrow.size = Vector2(45, 30)
	arrow.modulate = Color(1.0, 0.80, 0.48)
	app._view_container().add_child(arrow)


func _line_rect_between(a: Vector2, b: Vector2) -> Dictionary:
	var mid := (a + b) * 0.5
	var length := maxf(32.0, a.distance_to(b))
	return {
		"position": mid - Vector2(length * 0.5, 10),
		"size": Vector2(length, 20),
	}


func _draw_hero_slug_stage(hero_id: int, origin: Vector2) -> void:
	var center := origin + Vector2(530, 375)
	app._draw_image(UI_HERO_SLUG_BG, center + Vector2(-705 - 77, -375), Vector2(1410, 750), true, Color(1, 1, 1, 0.88))
	app._draw_image(UI_HERO_SLUG_FX_H, center + Vector2(-835, -375), Vector2(1670, 750), true, Color(1, 1, 1, 0.26))
	app._draw_image(UI_HERO_SLUG_FX_C, center + Vector2(-545, -318), Vector2(1091, 550), true, Color(1, 1, 1, 0.42))
	app._draw_image(UI_HERO_SLUG_FX_D, center + Vector2(-484, -278), Vector2(967, 486), true, Color(1, 1, 1, 0.34))
	app._draw_image(UI_HERO_SLUG_FX_E, center + Vector2(-394, -209), Vector2(788, 362), true, Color(1, 1, 1, 0.38))
	app._draw_image(UI_HERO_SLUG_FX_I, center + Vector2(-450, -450), Vector2(900, 900), false, Color(1, 1, 1, 0.20))
	app._draw_image(UI_HERO_SLUG_FX_K, center + Vector2(-367, -395), Vector2(733, 733), false, Color(1, 1, 1, 0.22))
	for spark in [Vector2(-127, -241), Vector2(339, -206), Vector2(135, 171), Vector2(-301, 138)]:
		app._draw_image(UI_HERO_SLUG_SPARK, center + spark - Vector2(65, 82), Vector2(131, 164), false, Color(1, 1, 1, 0.38))
	_draw_hero_slug_slot(hero_id, 1, center + Vector2(2, 70), true)
	_draw_hero_slug_slot(hero_id, 2, center + Vector2(-267, -94), false)
	_draw_hero_slug_slot(hero_id, 3, center + Vector2(2, -214), false)
	_draw_hero_slug_slot(hero_id, 4, center + Vector2(266, -94), false)
	app._draw_image(UI_HERO_SLUG_MID, center + Vector2(-140, -41), Vector2(280, 250), false, Color(1, 1, 1, 0.92))
	app._draw_image(UI_HERO_SLUG_MID_A, center + Vector2(-141, -120), Vector2(283, 241), false, Color(1, 1, 1, 0.72))
	app._draw_image(UI_HERO_SLUG_MID_B, center + Vector2(-126, -109), Vector2(254, 215), false, Color(1, 1, 1, 0.70))
	app._draw_image(UI_HERO_SLUG_MID_C, center + Vector2(-126, -109), Vector2(254, 215), false, Color(1, 1, 1, 0.54))
	app._draw_image(UI_HERO_EQUIP_SELECT, center + Vector2(-110, -110), Vector2(220, 220), false, Color(1, 1, 1, 0.68))
	app._draw_image(UI_HERO_SLUG_LIMIT_BG, center + Vector2(-120, -80), Vector2(280, 34), false, Color(1, 1, 1, 0.82))
	var limit: Label = app._label("同属性限制:", 18)
	limit.position = center + Vector2(-95, -80)
	limit.size = Vector2(120, 30)
	limit.modulate = Color(0.96, 0.88, 0.72)
	app._view_container().add_child(limit)
	for i in range(3):
		app._draw_image(UI_HERO_SLUG_LIMIT_TYPE, center + Vector2(19 + i * 40.0, -81), Vector2(36, 36), false, Color(1, 1, 1, 0.86))


func _draw_hero_slug_slot(hero_id: int, slot: int, center: Vector2, is_main: bool) -> void:
	var level := _hero_slug_level(hero_id, slot)
	var slot_size := Vector2(270, 110) if is_main else Vector2(216, 88)
	var base_path := UI_HERO_SLUG_SLOT_MAIN if is_main else UI_HERO_SLUG_SLOT
	app._draw_image(base_path, center - slot_size * 0.5, slot_size, false, Color(1, 1, 1, 0.92 if level > 0 else 0.54))
	if level > 0:
		var icon_size := Vector2(320, 320) if is_main else Vector2(220, 220)
		app._draw_image(UI_HERO_SLUG_ICON, center + Vector2(1, -19 if is_main else -11), icon_size, true, Color(1, 1, 1, 0.86))
		app._draw_image(UI_HERO_SLUG_NAME_BG, center + Vector2(-101 if is_main else -81, 146 if is_main else 99), Vector2(202 if is_main else 162, 34 if is_main else 27), false, Color(1, 1, 1, 0.90))
		var name: Label = app._label(_hero_slug_name(hero_id, slot), 20 if is_main else 16, HORIZONTAL_ALIGNMENT_CENTER)
		name.position = center + Vector2(-80, 148 if is_main else 100)
		name.size = Vector2(160, 30)
		name.modulate = Color(1.0, 0.92, 0.70)
		app._view_container().add_child(name)
	else:
		var lock: Label = app._label("未装备", 18, HORIZONTAL_ALIGNMENT_CENTER)
		lock.position = center + Vector2(-80, -15)
		lock.size = Vector2(160, 30)
		lock.modulate = Color(0.72, 0.70, 0.72)
		app._view_container().add_child(lock)
	app._draw_image(UI_HERO_SLUG_INFO_MAIN if is_main else UI_HERO_SLUG_INFO_SUB, center + Vector2(-99, -146), Vector2(198, 96), false, Color(1, 1, 1, 0.86))
	var info: Label = app._label("主战" if is_main else "辅助", 18, HORIZONTAL_ALIGNMENT_CENTER)
	info.position = center + Vector2(-26, -73)
	info.size = Vector2(52, 25)
	info.modulate = Color(1.0, 0.92, 0.74)
	app._view_container().add_child(info)
	app._add_hit_button(center - slot_size * 0.5, slot_size + Vector2(0, 80), func() -> void:
		_upgrade_hero_slug(hero_id, slot)
	)


func _draw_hero_slug_tabs(hero_id: int, pos: Vector2) -> void:
	for i in range(4):
		var tab_pos := pos + Vector2(i * 94.0, 0)
		app._draw_image(UI_HERO_SLUG_TAB_BASE, tab_pos, Vector2(84, 84), false, Color(1, 1, 1, 0.86))
		if i == 0:
			app._draw_image(UI_HERO_SLUG_TAB_SELECT, tab_pos - Vector2(8, 8), Vector2(100, 100), false, Color(1, 1, 1, 0.82))
		app._draw_image(UI_HERO_SLUG_ICON, tab_pos + Vector2(9, 9), Vector2(66, 66), true, Color(1, 1, 1, 0.90 if _hero_slug_level(hero_id, i + 1) > 0 else 0.42))
		var slot := i + 1
		app._add_hit_button(tab_pos, Vector2(84, 84), func() -> void:
			_upgrade_hero_slug(hero_id, slot)
		)


func _draw_hero_slug_top_buttons(pos: Vector2) -> void:
	var buttons := [
		{"path": UI_HERO_SLUG_MANUAL, "text": "源神录", "offset": Vector2(-936, 67)},
		{"path": UI_HERO_SLUG_DRAW, "text": "召唤", "offset": Vector2(-846, 67)},
		{"path": UI_HERO_SLUG_PASS, "text": "分解", "offset": Vector2(-756, 67)},
	]
	for item in buttons:
		var button_pos: Vector2 = pos + Vector2(item.get("offset", Vector2.ZERO))
		app._draw_image(str(item.get("path", "")), button_pos, Vector2(72, 72), false, Color(1, 1, 1, 0.84))
		var label: Label = app._label(str(item.get("text", "")), 14, HORIZONTAL_ALIGNMENT_CENTER)
		label.position = button_pos + Vector2(0, 66)
		label.size = Vector2(72, 24)
		label.modulate = Color(0.95, 0.88, 0.72)
		app._view_container().add_child(label)


func _draw_hero_main_bond_content(hero: Dictionary, pos: Vector2) -> void:
	var hero_id := int(hero.get("id", 0))
	var bond := int(app.save.get("hero_bonds", {}).get(str(hero_id), 0))
	var favorite := _favorite_heroes().has(str(hero_id))
	_draw_hero_main_panel_header("羈絆", pos)
	var lines := [
		"羈絆等級 Lv.%d" % bond,
		"收藏狀態：%s" % ("已收藏" if favorite else "未收藏"),
		"主看板：%s" % ("是" if int(app.save.get("selected_hero_id", DEFAULT_HERO_ID)) == hero_id else "否"),
		"Gal 看板：%s" % ("是" if int(app.save.get("selected_gal_hero_id", 0)) == hero_id else "否"),
	]
	for index in range(lines.size()):
		var label: Label = app._label(str(lines[index]), 17)
		label.position = pos + Vector2(54, 104 + index * 42)
		label.size = Vector2(320, 30)
		label.modulate = Color(0.96, 0.88, 0.82)
		app._view_container().add_child(label)
	app._add_action_button("羈絆 +1", pos + Vector2(256, 468), func() -> void:
		_raise_hero_bond(hero_id)
	, Vector2(132, 42), UI_COMMON_BTN_GOLD)
	app._add_action_button("進入Gal", pos + Vector2(256, 520), func() -> void:
		_set_hero_as_gal(hero_id, true)
	, Vector2(132, 42), UI_COMMON_BTN_WHITE)
	app._add_action_button("收藏切換", pos + Vector2(244, 572), func() -> void:
		_toggle_favorite_hero(hero_id)
	, Vector2(150, 42), UI_COMMON_BTN_WHITE)


func _draw_hero_detail_tabs(hero: Dictionary, pos: Vector2) -> void:
	var tabs := [
		{"key": "overview", "text": "總覽"},
		{"key": "core", "text": "核心"},
		{"key": "attrs", "text": "屬性"},
		{"key": "skills", "text": "技能"},
		{"key": "equip", "text": "靈裝"},
		{"key": "bond", "text": "羈絆"},
	]
	var x := pos.x
	for raw_tab in tabs:
		var tab: Dictionary = raw_tab
		var tab_key := str(tab.get("key", "overview"))
		var is_selected := tab_key == hero_detail_tab
		if is_selected:
			app._draw_image(UI_COMMON_TAB_HIGHLIGHT, Vector2(x, pos.y), Vector2(92, 48), false, Color(1, 1, 1, 0.92))
		else:
			app._view_container().add_child(app._panel(Vector2(x + 6, pos.y + 6), Vector2(80, 36), Color(0.075, 0.058, 0.083, 0.62)))
		var label: Label = app._label(str(tab.get("text", "")), 18, HORIZONTAL_ALIGNMENT_CENTER)
		label.position = Vector2(x + 8, pos.y + 8)
		label.size = Vector2(76, 28)
		label.modulate = Color(1.0, 0.92, 0.74) if is_selected else Color(0.82, 0.78, 0.78)
		app._view_container().add_child(label)
		var button_pos := Vector2(x, pos.y)
		var hero_id := int(hero.get("id", 0))
		var target_tab := tab_key
		app._add_hit_button(button_pos, Vector2(92, 48), func() -> void:
			hero_detail_tab = target_tab
			_show_hero_detail(hero_id)
		)
		x += 86.0


func _draw_hero_detail_info_view_frame(hero: Dictionary, pos: Vector2) -> void:
	var scale := HERO_DETAIL_INFO_SCALE
	var hero_id := int(hero.get("id", 0))
	var rarity := int(hero.get("rarity", 1))
	var key := str(hero_id)
	var level := int(app.save.get("hero_levels", {}).get(key, 1))
	var promotion := int(app.save.get("hero_promotions", {}).get(key, 0))
	var copies := int(app.save.get("owned", {}).get(key, 0))
	var shards := int(app.save.get("shards", {}).get(key, 0))
	var attrs := _hero_attrs(hero)

	app._draw_image(UI_HERO_DETAIL_INFO_BG, pos, HERO_DETAIL_INFO_SIZE, true, Color(1, 1, 1, 0.92))
	app._draw_image(UI_COMMON_HEAD_FRAME, pos + Vector2(12, 10) * scale, Vector2(140, 140) * scale, false, Color(1, 1, 1, 0.92))
	app._draw_hero_round_thumb(hero, pos + Vector2(19, 17) * scale, Vector2(126, 126) * scale, Color(1, 1, 1, 1))

	var title: Label = app._label(str(hero.get("name", "角色")), 24)
	title.position = pos + Vector2(166, 17) * scale
	title.size = Vector2(180, 32)
	title.modulate = Color(1.0, 0.92, 0.76)
	app._view_container().add_child(title)

	var subtitle: Label = app._label("Lv.%d  Spine %s" % [level, str(hero.get("spine", ""))], 13)
	subtitle.position = pos + Vector2(166, 54) * scale
	subtitle.size = Vector2(230, 22)
	subtitle.modulate = Color(0.90, 0.84, 0.78)
	app._view_container().add_child(subtitle)

	var meta: Label = app._label("%s  %s  %s" % [_hero_camp_label(hero), _hero_occupation_label(hero), "已獲得" if copies > 0 else "未獲得"], 13)
	meta.position = pos + Vector2(166, 82) * scale
	meta.size = Vector2(280, 22)
	meta.modulate = Color(0.92, 0.86, 0.78)
	app._view_container().add_child(meta)

	app._draw_image(UI_COMMON_RARE_BADGE, pos + Vector2(416, 10) * scale, Vector2(120, 54) * scale, false, Color(1, 1, 1, 0.86))
	var rare_label: Label = app._label("R%d" % rarity, 17, HORIZONTAL_ALIGNMENT_CENTER)
	rare_label.position = pos + Vector2(420, 20) * scale
	rare_label.size = Vector2(54, 22)
	rare_label.modulate = Color(1.0, 0.88, 0.62)
	app._view_container().add_child(rare_label)
	for i in range(clamp(rarity, 1, 5)):
		app._draw_image(UI_COMMON_STAR, pos + Vector2(158 + i * 34, 98) * scale, Vector2(44, 44) * scale, false, Color(1, 1, 1, 0.95))
	if promotion > 0:
		var promotion_label: Label = app._label("+%d" % promotion, 14, HORIZONTAL_ALIGNMENT_CENTER)
		promotion_label.position = pos + Vector2(328, 103) * scale
		promotion_label.size = Vector2(42, 20)
		promotion_label.modulate = Color(1.0, 0.78, 0.42)
		app._view_container().add_child(promotion_label)

	var shard_label: Label = app._label("碎片 %d/%d" % [shards, _hero_unlock_shard_cost(hero)], 12, HORIZONTAL_ALIGNMENT_RIGHT)
	shard_label.position = pos + Vector2(398, 118) * scale
	shard_label.size = Vector2(120, 20)
	shard_label.modulate = Color(0.96, 0.82, 0.58)
	app._view_container().add_child(shard_label)

	_draw_hero_detail_section_header("屬性詳情", pos + Vector2(16, 187) * scale, Vector2(510, 30) * scale)
	var entries := [
		["攻擊", str(attrs.get("攻擊", ""))],
		["防禦", str(attrs.get("防禦", ""))],
		["傷害+", str(attrs.get("傷害+", ""))],
		["命中", str(attrs.get("命中", ""))],
		["暴擊", str(attrs.get("暴擊", ""))],
		["生命", str(attrs.get("生命", ""))],
		["速度", str(attrs.get("速度", ""))],
		["減免", str(attrs.get("減免", ""))],
		["抗暴", str(attrs.get("抗暴", ""))],
		["戰力", str(attrs.get("戰力", ""))],
	]
	for index in range(entries.size()):
		var col := index / 5
		var row := index % 5
		var item: Array = entries[index]
		var item_pos := pos + Vector2(23 + col * 250, 232 + row * 27) * scale
		_draw_hero_detail_attr(str(item[0]), str(item[1]), item_pos, scale)


func _show_hero_detail_info_modal(hero_id: int) -> void:
	var hero: Dictionary = app._hero_by_id(hero_id)
	_show_hero_detail(hero_id)
	app._view_container().add_child(app._panel(Vector2(0, 0), app.CANVAS_SIZE, Color(0.0, 0.0, 0.0, 0.52)))
	_draw_hero_detail_info_full(hero, HERO_DETAIL_INFO_MODAL_POS)
	app._add_action_button("關閉", HERO_DETAIL_INFO_MODAL_POS + Vector2(936, 548), func() -> void:
		_show_hero_detail(hero_id)
	, Vector2(112, 42), UI_COMMON_BTN_WHITE)


func _draw_hero_detail_info_full(hero: Dictionary, pos: Vector2) -> void:
	var hero_id := int(hero.get("id", 0))
	var rarity := int(hero.get("rarity", 1))
	var key := str(hero_id)
	var level := int(app.save.get("hero_levels", {}).get(key, 1))
	var promotion := int(app.save.get("hero_promotions", {}).get(key, 0))
	var copies := int(app.save.get("owned", {}).get(key, 0))
	var shards := int(app.save.get("shards", {}).get(key, 0))
	var attrs := _hero_attrs(hero)

	app._draw_image(UI_HERO_DETAIL_INFO_BG, pos, HERO_DETAIL_INFO_MODAL_SIZE, true, Color(1, 1, 1, 0.97))
	app._draw_image(UI_COMMON_HEAD_FRAME, pos + Vector2(12, 10), Vector2(140, 140), false, Color(1, 1, 1, 0.94))
	app._draw_hero_round_thumb(hero, pos + Vector2(19, 17), Vector2(126, 126), Color(1, 1, 1, 1))

	var title: Label = app._label(str(hero.get("name", "角色")), 40)
	title.position = pos + Vector2(166, 34)
	title.size = Vector2(232, 52)
	title.modulate = Color(1.0, 0.92, 0.76)
	app._view_container().add_child(title)
	var subtitle: Label = app._label("Lv.%d  %s  %s" % [level, _hero_camp_label(hero), _hero_occupation_label(hero)], 22)
	subtitle.position = pos + Vector2(166, 10)
	subtitle.size = Vector2(300, 28)
	subtitle.modulate = Color(0.90, 0.84, 0.78)
	app._view_container().add_child(subtitle)
	app._draw_image(UI_COMMON_RARE_BADGE, pos + Vector2(406, 14), Vector2(120, 54), false, Color(1, 1, 1, 0.90))
	var rare_label: Label = app._label("R%d" % rarity, 18, HORIZONTAL_ALIGNMENT_CENTER)
	rare_label.position = pos + Vector2(416, 25)
	rare_label.size = Vector2(58, 24)
	rare_label.modulate = Color(1.0, 0.88, 0.62)
	app._view_container().add_child(rare_label)
	for i in range(5):
		app._draw_image(UI_COMMON_STAR if i < clamp(rarity, 1, 5) else UI_COMMON_STAR_OFF, pos + Vector2(158 + i * 34, 98), Vector2(44, 44), false, Color(1, 1, 1, 0.95))
	if promotion > 0:
		var promotion_label: Label = app._label("+%d" % promotion, 18, HORIZONTAL_ALIGNMENT_CENTER)
		promotion_label.position = pos + Vector2(330, 108)
		promotion_label.size = Vector2(46, 24)
		promotion_label.modulate = Color(1.0, 0.78, 0.42)
		app._view_container().add_child(promotion_label)
	var meta: Label = app._label("%s  碎片 %d/%d" % ["已獲得" if copies > 0 else "未獲得", shards, _hero_unlock_shard_cost(hero)], 18, HORIZONTAL_ALIGNMENT_RIGHT)
	meta.position = pos + Vector2(356, 116)
	meta.size = Vector2(170, 26)
	meta.modulate = Color(0.96, 0.82, 0.58)
	app._view_container().add_child(meta)

	_draw_hero_detail_section_header("屬性詳情", pos + Vector2(16, 187), Vector2(510, 30))
	var attr_entries := [
		["攻擊", str(attrs.get("攻擊", ""))],
		["防禦", str(attrs.get("防禦", ""))],
		["傷害+", str(attrs.get("傷害+", ""))],
		["命中", str(attrs.get("命中", ""))],
		["暴擊", str(attrs.get("暴擊", ""))],
		["生命", str(attrs.get("生命", ""))],
		["速度", str(attrs.get("速度", ""))],
		["減免", str(attrs.get("減免", ""))],
		["抗暴", str(attrs.get("抗暴", ""))],
		["戰力", str(attrs.get("戰力", ""))],
	]
	for index in range(attr_entries.size()):
		var col := int(index / 5)
		var row := index % 5
		var item: Array = attr_entries[index]
		_draw_hero_detail_attr(str(item[0]), str(item[1]), pos + Vector2(38 + col * 244.0, 232 + row * 31.0), 1.0)

	_draw_hero_detail_section_header("技能", pos + Vector2(16, 426), Vector2(510, 30))
	var skill_paths: Array = hero.get("skillResources", [])
	for i in range(4):
		var icon_pos := pos + Vector2(64 + i * 110.0, 470)
		app._draw_image(UI_COMMON_SKILL_FRAME, icon_pos, Vector2(84, 84), false, Color(1, 1, 1, 0.84))
		if i < skill_paths.size():
			app._draw_image(app._godot_resource_path(str(skill_paths[i])), icon_pos + Vector2(9, 9), Vector2(66, 66), false)
		var skill_label: Label = app._label("Lv.%d" % _hero_skill_level(hero_id, i), 12, HORIZONTAL_ALIGNMENT_CENTER)
		skill_label.position = icon_pos + Vector2(4, 64)
		skill_label.size = Vector2(76, 18)
		app._view_container().add_child(skill_label)

	var right_x := pos.x + 550
	_draw_hero_detail_equipment_full(hero_id, "equip", "靈裝", Vector2(right_x, pos.y + 10))
	_draw_hero_detail_equipment_full(hero_id, "slug", "源神", Vector2(right_x, pos.y + 187))
	_draw_hero_detail_equipment_full(hero_id, "weapon", "神具", Vector2(right_x, pos.y + 363))


func _draw_hero_detail_equipment_full(hero_id: int, kind: String, title: String, pos: Vector2) -> void:
	_draw_hero_detail_section_header(title, pos, Vector2(510, 30))
	for slot_index in range(4):
		var slot := slot_index + 1
		var slot_pos := pos + Vector2(30 + slot_index * 92.0, 48)
		var level := _hero_equipment_level(hero_id, kind, 1 if slot_index < 2 else 2)
		app._draw_image(UI_COMMON_SKILL_FRAME, slot_pos, Vector2(72, 72), false, Color(1.0, 0.86, 0.28, 0.42 if level <= 0 else 0.88))
		var symbol: Label = app._label(_hero_equipment_symbol(kind), 24, HORIZONTAL_ALIGNMENT_CENTER)
		symbol.position = slot_pos + Vector2(8, 14)
		symbol.size = Vector2(56, 32)
		symbol.modulate = Color(1.0, 0.94, 0.70)
		app._view_container().add_child(symbol)
		var level_label: Label = app._label("Lv.%d" % level, 11, HORIZONTAL_ALIGNMENT_CENTER)
		level_label.position = slot_pos + Vector2(4, 52)
		level_label.size = Vector2(64, 16)
		app._view_container().add_child(level_label)


func _draw_hero_detail_summary(hero: Dictionary, pos: Vector2) -> void:
	var hero_id := int(hero.get("id", 0))
	var rarity := int(hero.get("rarity", 1))
	var key := str(hero_id)
	var copies := int(app.save.get("owned", {}).get(key, 0))
	var shards := int(app.save.get("shards", {}).get(key, 0))
	var owned := copies > 0

	app._draw_image(UI_COMMON_HEAD_FRAME, pos, Vector2(118, 118), false, Color(1, 1, 1, 0.92))
	app._draw_hero_round_thumb(hero, pos + Vector2(10, 10), Vector2(98, 98), Color(1, 1, 1, 1) if owned else Color(0.48, 0.48, 0.50, 1))

	var title: Label = app._label(str(hero.get("name", "角色")), 34)
	title.position = pos + Vector2(136, 4)
	title.size = Vector2(240, 48)
	title.modulate = Color(1.0, 0.92, 0.76)
	app._view_container().add_child(title)

	var spine: Label = app._label("Spine  %s" % str(hero.get("spine", "")), 17)
	spine.position = pos + Vector2(138, 52)
	spine.size = Vector2(280, 26)
	spine.modulate = Color(0.90, 0.84, 0.78)
	app._view_container().add_child(spine)

	app._view_container().add_child(app._panel(pos + Vector2(388, 10), Vector2(98, 44), app._rarity_color(rarity, 0.50)))
	var rare_label: Label = app._label("R%d" % rarity, 20, HORIZONTAL_ALIGNMENT_CENTER)
	rare_label.position = pos + Vector2(388, 18)
	rare_label.size = Vector2(98, 28)
	rare_label.modulate = Color(1.0, 0.92, 0.72)
	app._view_container().add_child(rare_label)
	_draw_hero_card_stars(rarity, pos + Vector2(136, 86), 28)

	var state_text := "已獲得  持有 %d  碎片 %d" % [copies, shards] if owned else "未獲得  碎片 %d" % shards
	var state: Label = app._label(state_text, 18)
	state.position = pos + Vector2(300, 88)
	state.size = Vector2(220, 28)
	state.modulate = Color(1.0, 0.82, 0.58)
	app._view_container().add_child(state)

	var power_panel: ColorRect = app._panel(pos + Vector2(0, 144), Vector2(496, 52), Color(0.07, 0.052, 0.075, 0.78))
	app._view_container().add_child(power_panel)
	var power: Label = app._label("戰力  %d" % _hero_power(hero), 24)
	power.position = pos + Vector2(22, 152)
	power.size = Vector2(190, 36)
	power.modulate = Color(1.0, 0.82, 0.45)
	app._view_container().add_child(power)
	var route: Label = app._label("獲得途徑  喚靈 / 祈願 / 活動", 17, HORIZONTAL_ALIGNMENT_RIGHT)
	route.position = pos + Vector2(214, 156)
	route.size = Vector2(260, 30)
	route.modulate = Color(0.92, 0.86, 0.82)
	app._view_container().add_child(route)


func _draw_hero_detail_notice(pos: Vector2) -> void:
	var notice := str(app.save.get("hero_detail_notice", ""))
	if notice.is_empty():
		return
	var note: Label = app._label(notice, 16, HORIZONTAL_ALIGNMENT_CENTER)
	note.position = pos
	note.size = Vector2(496, 28)
	note.modulate = Color(1.0, 0.88, 0.58)
	app._view_container().add_child(note)


func _draw_hero_detail_info_panel(hero: Dictionary, pos: Vector2) -> void:
	var scale := HERO_DETAIL_INFO_SCALE
	var hero_id := int(hero.get("id", 0))
	_draw_hero_detail_section_header("技能列表", pos + Vector2(0, 88) * scale, Vector2(510, 30) * scale)
	var skill_paths: Array = hero.get("skillResources", [])
	for i in range(4):
		var icon_pos := pos + Vector2(42 + i * 110.0, 132) * scale
		var icon_size := Vector2(84, 84) * scale
		app._draw_image(UI_COMMON_SKILL_FRAME, icon_pos, icon_size, false, Color(1, 1, 1, 0.82))
		if i < skill_paths.size():
			app._draw_image(app._godot_resource_path(str(skill_paths[i])), icon_pos + Vector2(7, 7), icon_size - Vector2(14, 14), false)
		var skill_label: Label = app._label("技能%d" % (i + 1), 11, HORIZONTAL_ALIGNMENT_CENTER)
		skill_label.position = icon_pos + Vector2(-2, 42)
		skill_label.size = Vector2(46, 18)
		app._view_container().add_child(skill_label)
		var skill_level: Label = app._label("Lv.%d" % _hero_skill_level(hero_id, i), 10, HORIZONTAL_ALIGNMENT_CENTER)
		skill_level.position = icon_pos + Vector2(-2, 58)
		skill_level.size = Vector2(46, 14)
		skill_level.modulate = Color(1.0, 0.86, 0.58)
		app._view_container().add_child(skill_level)

	var sections: Array = [
		{"key": "equip", "title": "靈裝", "offset": Vector2(0, 242)},
		{"key": "slug", "title": "源神", "offset": Vector2(520, 88)},
		{"key": "weapon", "title": "神具", "offset": Vector2(520, 242)},
	]
	for raw_section in sections:
		var section: Dictionary = raw_section
		var section_pos: Vector2 = pos + Vector2(section.get("offset", Vector2.ZERO)) * scale
		_draw_hero_detail_section_header(str(section.get("title", "")), section_pos, Vector2(500, 30) * scale)
		for slot_index in range(2):
			var slot := slot_index + 1
			var slot_pos := section_pos + Vector2(26 + slot_index * 64.0, 42)
			var level := _hero_equipment_level(hero_id, str(section.get("key", "")), slot)
			app._draw_image(UI_COMMON_SKILL_FRAME, slot_pos, Vector2(52, 52), false, Color(1.0, 0.86, 0.28, 0.44 if level <= 0 else 0.86))
			var symbol: Label = app._label(_hero_equipment_symbol(str(section.get("key", ""))), 17, HORIZONTAL_ALIGNMENT_CENTER)
			symbol.position = slot_pos + Vector2(4, 9)
			symbol.size = Vector2(44, 24)
			symbol.modulate = Color(1.0, 0.92, 0.66)
			app._view_container().add_child(symbol)
			var level_label: Label = app._label("Lv.%d" % level, 10, HORIZONTAL_ALIGNMENT_CENTER)
			level_label.position = slot_pos + Vector2(2, 35)
			level_label.size = Vector2(48, 14)
			level_label.modulate = Color(0.94, 0.86, 0.72)
			app._view_container().add_child(level_label)


func _draw_hero_detail_tab_content(hero: Dictionary, pos: Vector2) -> void:
	match hero_detail_tab:
		"core":
			_draw_hero_core_tab(hero, pos)
		"attrs":
			_draw_hero_attrs_tab(hero, pos)
		"skills":
			_draw_hero_skills_tab(hero, pos)
		"equip":
			_draw_hero_equip_tab(hero, pos)
		"slug":
			_draw_hero_slug_tab(hero, pos)
		"weapon":
			_draw_hero_weapon_tab(hero, pos)
		"upstage":
			_draw_hero_upstage_tab(hero, pos)
		"bond":
			_draw_hero_bond_tab(hero, pos)
		_:
			_draw_hero_detail_info_panel(hero, pos)


func _draw_hero_attrs_tab(hero: Dictionary, pos: Vector2) -> void:
	var scale := HERO_DETAIL_INFO_SCALE
	_draw_hero_detail_section_header("屬性成長", pos, Vector2(510, 30) * scale)
	_draw_hero_detail_section_header("培養操作", pos + Vector2(520, 0) * scale, Vector2(500, 30) * scale)
	var attrs := _hero_attrs(hero)
	var index := 0
	for key in attrs.keys():
		var col := index / 4
		var row := index % 4
		var cell_pos := pos + Vector2(23 + col * 250.0, 48 + row * 30.0) * scale
		_draw_hero_detail_attr(str(key), str(attrs[key]), cell_pos, scale)
		index += 1
	var hero_id := int(hero.get("id", 0))
	var level := int(app.save.get("hero_levels", {}).get(str(hero_id), 1))
	app._add_action_button("培養 +1", pos + Vector2(302, 74), func() -> void:
		_train_hero(hero_id)
	, Vector2(132, 42), UI_COMMON_BTN_GOLD)
	app._add_action_button("升星", pos + Vector2(302, 126), func() -> void:
		_promote_hero(hero_id)
	, Vector2(132, 42), UI_COMMON_BTN_WHITE)
	var tip: Label = app._label("等級 Lv.%d\n培養會提升本地戰力，升星消耗碎片。" % level, 15)
	tip.position = pos + Vector2(302, 178)
	tip.size = Vector2(196, 48)
	tip.modulate = Color(0.92, 0.86, 0.82)
	app._view_container().add_child(tip)


func _draw_hero_core_tab(hero: Dictionary, pos: Vector2) -> void:
	_draw_hero_detail_section_header("核心", pos, Vector2(510, 30) * HERO_DETAIL_INFO_SCALE)
	_draw_hero_detail_section_header("核心操作", pos + Vector2(520, 0) * HERO_DETAIL_INFO_SCALE, Vector2(500, 30) * HERO_DETAIL_INFO_SCALE)
	var hero_id := int(hero.get("id", 0))
	var core_levels: Dictionary = _hero_state_dict("hero_core_levels")
	var center: Vector2 = pos + Vector2(156, 118)
	app._draw_hero_round_thumb(hero, center - Vector2(34, 34), Vector2(68, 68), Color(1, 1, 1, 1))
	app._draw_image(UI_COMMON_HERO_HEAD_FRAME, center - Vector2(34, 34), Vector2(68, 68), false, Color(1, 1, 1, 0.90))
	var slots := [
		Vector2(-116, -56),
		Vector2(116, -56),
		Vector2(-116, 56),
		Vector2(116, 56),
	]
	for index in range(slots.size()):
		var slot: int = index + 1
		var slot_key := _hero_slot_key(hero_id, slot)
		var level: int = int(core_levels.get(slot_key, 0))
		var slot_offset: Vector2 = slots[index]
		var slot_pos: Vector2 = center + slot_offset - Vector2(30, 30)
		app._draw_image(UI_COMMON_SKILL_FRAME, slot_pos + Vector2(4, 4), Vector2(52, 52), false, Color(1.0, 0.82, 0.36, 0.40 if level <= 0 else 0.86))
		var title: Label = app._label(str(slot), 15, HORIZONTAL_ALIGNMENT_CENTER)
		title.position = slot_pos + Vector2(10, 8)
		title.size = Vector2(40, 20)
		app._view_container().add_child(title)
		var level_label: Label = app._label("Lv.%d" % level, 11, HORIZONTAL_ALIGNMENT_CENTER)
		level_label.position = slot_pos + Vector2(4, 36)
		level_label.size = Vector2(52, 16)
		level_label.modulate = Color(1.0, 0.92, 0.68)
		app._view_container().add_child(level_label)
		var target_slot: int = slot
		app._add_hit_button(slot_pos, Vector2(60, 60), func() -> void:
			_upgrade_hero_core(hero_id, target_slot)
		)
	app._add_action_button("一鍵核心", pos + Vector2(302, 74), func() -> void:
		_upgrade_all_hero_cores(hero_id)
	, Vector2(132, 42), UI_COMMON_BTN_GOLD)
	app._add_action_button("核心詳情", pos + Vector2(302, 126), func() -> void:
		_set_hero_notice("核心位對應原版 pnlCore/btnPos1-4")
		app._persist()
		_show_hero_detail(hero_id)
	, Vector2(132, 42), UI_COMMON_BTN_WHITE)
	var total: int = _hero_core_total(hero_id)
	var tip: Label = app._label("四個核心位可點擊升級。\n核心總等級 %d，會提升戰力。" % total, 15)
	tip.position = pos + Vector2(302, 178)
	tip.size = Vector2(198, 48)
	tip.modulate = Color(0.92, 0.86, 0.82)
	app._view_container().add_child(tip)


func _draw_hero_skills_tab(hero: Dictionary, pos: Vector2) -> void:
	_draw_hero_detail_section_header("技能", pos, Vector2(510, 30) * HERO_DETAIL_INFO_SCALE)
	_draw_hero_detail_section_header("技能操作", pos + Vector2(520, 0) * HERO_DETAIL_INFO_SCALE, Vector2(500, 30) * HERO_DETAIL_INFO_SCALE)
	var hero_id := int(hero.get("id", 0))
	var skill_paths: Array = hero.get("skillResources", [])
	var selected_skill: int = clampi(int(app.save.get("hero_selected_skill", 0)), 0, 3)
	for i in range(4):
		var icon_pos: Vector2 = pos + Vector2(34 + i * 58.0, 74)
		if i == selected_skill:
			app._view_container().add_child(app._panel(icon_pos - Vector2(4, 4), Vector2(56, 78), Color(0.86, 0.60, 0.24, 0.24)))
		app._draw_image(UI_COMMON_SKILL_FRAME, icon_pos, Vector2(48, 48), false, Color(1, 1, 1, 0.78))
		if i < skill_paths.size():
			app._draw_image(app._godot_resource_path(str(skill_paths[i])), icon_pos + Vector2(4, 4), Vector2(40, 40), false)
		var skill_level: int = _hero_skill_level(hero_id, i)
		var skill_label: Label = app._label("Lv.%d" % skill_level, 12, HORIZONTAL_ALIGNMENT_CENTER)
		skill_label.position = icon_pos + Vector2(-2, 50)
		skill_label.size = Vector2(52, 20)
		app._view_container().add_child(skill_label)
		var skill_index: int = i
		app._add_hit_button(icon_pos, Vector2(48, 70), func() -> void:
			_select_hero_skill(hero_id, skill_index)
		)
	app._add_action_button("升級技能%d" % (selected_skill + 1), pos + Vector2(302, 74), func() -> void:
		_upgrade_hero_skill(hero_id, selected_skill)
	, Vector2(150, 42), UI_COMMON_BTN_GOLD)
	app._add_action_button("查看演示", pos + Vector2(302, 126), func() -> void:
		app.save["hero_last_skill_preview"] = "%s:%d" % [hero_id, selected_skill]
		_set_hero_notice("已標記技能 %d 演示" % (selected_skill + 1))
		app._persist()
		_show_hero_detail(hero_id)
	, Vector2(150, 42), UI_COMMON_BTN_WHITE)
	var desc: Label = app._label("當前選中技能 %d。升級會記錄技能等級並刷新詳情。" % (selected_skill + 1), 15)
	desc.position = pos + Vector2(302, 182)
	desc.size = Vector2(196, 42)
	desc.modulate = Color(0.92, 0.86, 0.82)
	app._view_container().add_child(desc)


func _draw_hero_equip_tab(hero: Dictionary, pos: Vector2) -> void:
	var hero_id := int(hero.get("id", 0))
	var sections: Array = [
		{"key": "equip", "title": "靈裝"},
		{"key": "slug", "title": "源神"},
		{"key": "weapon", "title": "神具"},
	]
	for index in range(sections.size()):
		var section: Dictionary = sections[index]
		var section_pos: Vector2 = pos + Vector2(18 + index * 170.0, 18)
		_draw_hero_section_header(str(section.get("title", "")), section_pos, Vector2(150, 30))
		for slot_index in range(2):
			var slot: int = slot_index + 1
			var item_pos: Vector2 = section_pos + Vector2(14 + slot_index * 68.0, 54)
			var level: int = _hero_equipment_level(hero_id, str(section.get("key", "")), slot)
			app._draw_image(UI_COMMON_SKILL_FRAME, item_pos, Vector2(58, 58), false, Color(1.0, 0.86, 0.28, 0.42 if level <= 0 else 0.88))
			var symbol: Label = app._label(_hero_equipment_symbol(str(section.get("key", ""))), 22, HORIZONTAL_ALIGNMENT_CENTER)
			symbol.position = item_pos + Vector2(4, 12)
			symbol.size = Vector2(50, 28)
			symbol.modulate = Color(1.0, 0.94, 0.70)
			app._view_container().add_child(symbol)
			var level_label: Label = app._label("Lv.%d" % level, 11, HORIZONTAL_ALIGNMENT_CENTER)
			level_label.position = item_pos + Vector2(2, 42)
			level_label.size = Vector2(54, 14)
			app._view_container().add_child(level_label)
			var target_kind: String = str(section.get("key", "equip"))
			var target_slot: int = slot
			app._add_hit_button(item_pos, Vector2(58, 58), func() -> void:
				_upgrade_hero_equipment(hero_id, target_kind, target_slot)
			)
	app._add_action_button("一鍵強化", pos + Vector2(302, 154), func() -> void:
		_upgrade_all_hero_equipment(hero_id)
	, Vector2(132, 42), UI_COMMON_BTN_GOLD)
	var total: int = _hero_equipment_total(hero_id)
	var desc: Label = app._label("依 HeroDetailInfoView 的靈裝/源神/神具三區塊還原。\n點擊任一槽位可強化，總等級 %d。" % total, 15)
	desc.position = pos + Vector2(28, 158)
	desc.size = Vector2(250, 56)
	desc.modulate = Color(0.92, 0.86, 0.82)
	app._view_container().add_child(desc)


func _draw_hero_slug_tab(hero: Dictionary, pos: Vector2) -> void:
	var hero_id := int(hero.get("id", 0))
	_draw_hero_detail_section_header("源神", pos, Vector2(510, 30) * HERO_DETAIL_INFO_SCALE)
	var total := _hero_slug_total(hero_id)
	for i in range(4):
		var slot_pos := pos + Vector2(34 + i * 58.0, 74)
		app._draw_image(UI_HERO_SLUG_TAB_BASE, slot_pos, Vector2(48, 48), false, Color(1, 1, 1, 0.78))
		app._draw_image(UI_HERO_SLUG_ICON, slot_pos + Vector2(4, 4), Vector2(40, 40), true, Color(1, 1, 1, 0.80 if _hero_slug_level(hero_id, i + 1) > 0 else 0.36))
		var slot := i + 1
		app._add_hit_button(slot_pos, Vector2(48, 48), func() -> void:
			_upgrade_hero_slug(hero_id, slot)
		)
	var desc: Label = app._label("源神总等级 %d。点击任意源神位可提升本地等级。" % total, 15)
	desc.position = pos + Vector2(302, 74)
	desc.size = Vector2(198, 56)
	desc.modulate = Color(0.92, 0.86, 0.82)
	app._view_container().add_child(desc)
	app._add_action_button("一键装配", pos + Vector2(302, 154), func() -> void:
		_upgrade_all_hero_slugs(hero_id)
	, Vector2(132, 42), UI_COMMON_BTN_GOLD)


func _draw_hero_weapon_tab(hero: Dictionary, pos: Vector2) -> void:
	var hero_id := int(hero.get("id", 0))
	var level := _hero_weapon_level(hero_id)
	_draw_hero_detail_section_header("神具", pos, Vector2(510, 30) * HERO_DETAIL_INFO_SCALE)
	app._draw_image(UI_COMMON_SKILL_FRAME, pos + Vector2(44, 74), Vector2(72, 72), false, Color(1.0, 0.86, 0.34, 0.80 if level > 0 else 0.40))
	app._draw_image(UI_HERO_WEAPON_EMPTY_ICON, pos + Vector2(52, 82), Vector2(56, 56), false, Color(1, 1, 1, 0.88 if level > 0 else 0.44))
	var desc: Label = app._label("神具等级 Lv.%d。装备后提升专属属性。" % level, 15)
	desc.position = pos + Vector2(302, 74)
	desc.size = Vector2(198, 56)
	desc.modulate = Color(0.92, 0.86, 0.82)
	app._view_container().add_child(desc)
	app._add_action_button("锻造", pos + Vector2(302, 154), func() -> void:
		_upgrade_hero_weapon(hero_id)
	, Vector2(132, 42), UI_COMMON_BTN_GOLD)


func _draw_hero_upstage_tab(hero: Dictionary, pos: Vector2) -> void:
	var hero_id := int(hero.get("id", 0))
	var step := _hero_upstage_step(hero_id)
	_draw_hero_detail_section_header("升阶", pos, Vector2(510, 30) * HERO_DETAIL_INFO_SCALE)
	for i in range(6):
		var step_pos := pos + Vector2(28 + i * 44.0, 80)
		app._draw_image(UI_HERO_STAGE_STEP_ON if i < step else UI_HERO_STAGE_STEP_OFF, step_pos, Vector2(38, 38), false, Color(1, 1, 1, 0.86 if i < step else 0.42))
	var desc: Label = app._label("星格进度 %d/6。点亮后提升当前幻灵属性。" % step, 15)
	desc.position = pos + Vector2(302, 74)
	desc.size = Vector2(198, 56)
	desc.modulate = Color(0.92, 0.86, 0.82)
	app._view_container().add_child(desc)
	app._add_action_button("点亮星格", pos + Vector2(302, 154), func() -> void:
		_upgrade_hero_upstage(hero_id)
	, Vector2(132, 42), UI_COMMON_BTN_GOLD)


func _draw_hero_bond_tab(hero: Dictionary, pos: Vector2) -> void:
	_draw_hero_detail_section_header("羈絆", pos, Vector2(510, 30) * HERO_DETAIL_INFO_SCALE)
	_draw_hero_detail_section_header("互動入口", pos + Vector2(520, 0) * HERO_DETAIL_INFO_SCALE, Vector2(500, 30) * HERO_DETAIL_INFO_SCALE)
	var hero_id := int(hero.get("id", 0))
	var bond := int(app.save.get("hero_bonds", {}).get(str(hero_id), 0))
	var favorite := _favorite_heroes().has(str(hero_id))
	var lines := [
		"羈絆等級 Lv.%d" % bond,
		"收藏狀態：%s" % ("已收藏" if favorite else "未收藏"),
		"主看板：%s" % ("是" if int(app.save.get("selected_hero_id", DEFAULT_HERO_ID)) == hero_id else "否"),
		"Gal 看板：%s" % ("是" if int(app.save.get("selected_gal_hero_id", 0)) == hero_id else "否"),
	]
	for index in range(lines.size()):
		var label: Label = app._label(str(lines[index]), 16)
		label.position = pos + Vector2(34, 70 + index * 34)
		label.size = Vector2(220, 28)
		label.modulate = Color(0.96, 0.88, 0.82)
		app._view_container().add_child(label)
	app._add_action_button("羈絆 +1", pos + Vector2(302, 74), func() -> void:
		_raise_hero_bond(hero_id)
	, Vector2(132, 42), UI_COMMON_BTN_GOLD)
	app._add_action_button("進入Gal", pos + Vector2(302, 126), func() -> void:
		_set_hero_as_gal(hero_id, true)
	, Vector2(132, 42), UI_COMMON_BTN_WHITE)
	app._add_action_button("收藏切換", pos + Vector2(302, 178), func() -> void:
		_toggle_favorite_hero(hero_id)
	, Vector2(132, 42), UI_COMMON_BTN_WHITE)


func _draw_hero_detail_nav(hero_id: int) -> void:
	var filtered: Array = _detail_cycle_heroes(hero_id)
	if filtered.is_empty():
		return
	var index := _hero_index_in_list(filtered, hero_id)
	if index < 0:
		index = 0
	var prev_hero: Dictionary = filtered[posmod(index - 1, filtered.size())]
	var next_hero: Dictionary = filtered[posmod(index + 1, filtered.size())]
	var prev_id := int(prev_hero.get("id", hero_id))
	var next_id := int(next_hero.get("id", hero_id))
	app._add_action_button("<", HERO_DETAIL_STAGE_POS + Vector2(34, 606), func() -> void:
		_show_hero_detail(prev_id)
	, Vector2(48, 44), UI_COMMON_BTN_WHITE)
	app._add_action_button(">", HERO_DETAIL_STAGE_POS + Vector2(HERO_DETAIL_STAGE_SIZE.x - 82, 606), func() -> void:
		_show_hero_detail(next_id)
	, Vector2(48, 44), UI_COMMON_BTN_WHITE)


func _draw_hero_detail_filter_panel(hero_id: int) -> void:
	if not gallery_sort_open:
		return
	var panel_pos := HERO_DETAIL_FILTER_POS
	app._draw_image(UI_HERO_FILTER_BG, panel_pos, HERO_LIST_FILTER_PANEL_SIZE, false, Color(1, 1, 1, 0.96))
	var occupation_keys := ["all", "occupation1", "occupation2", "occupation3", "occupation4", "occupation5"]
	for index in range(occupation_keys.size()):
		var key := str(occupation_keys[index])
		var pos := panel_pos + Vector2(24 + index * 56.0, 25)
		var target_occupation := key
		_draw_hero_filter_icon(key, gallery_occupation_filter == key, str(UI_HERO_OCCUPATION_FILTER_ICONS[index]), pos, Vector2(42, 42), "全" if index == 0 else "", func() -> void:
			gallery_occupation_filter = target_occupation
			_show_hero_detail(hero_id)
		)
	var camp_keys := ["all", "camp1", "camp2", "camp3", "camp4", "camp5"]
	for index in range(camp_keys.size()):
		var key := str(camp_keys[index])
		var pos := panel_pos + Vector2(24 + index * 56.0, 79)
		var target_camp := key
		_draw_hero_filter_icon(key, gallery_camp_filter == key, str(UI_HERO_CAMP_FILTER_ICONS[index]), pos, Vector2(42, 42), "全" if index == 0 else "", func() -> void:
			gallery_camp_filter = target_camp
			_show_hero_detail(hero_id)
		)


func _draw_hero_attr(label_text: String, value_text: String, pos: Vector2) -> void:
	var label: Label = app._label(label_text, 15)
	label.position = pos
	label.size = Vector2(66, 24)
	label.modulate = Color(0.92, 0.86, 0.80)
	app._view_container().add_child(label)
	var value: Label = app._label(value_text, 15, HORIZONTAL_ALIGNMENT_RIGHT)
	value.position = pos + Vector2(58, 0)
	value.size = Vector2(52, 24)
	value.modulate = Color(1.0, 0.86, 0.60)
	app._view_container().add_child(value)


func _draw_hero_section_header(text: String, pos: Vector2, size: Vector2) -> void:
	app._draw_image(UI_COMMON_SECTION, pos, size, true, Color(1, 1, 1, 0.78))
	var label: Label = app._label(text, 15, HORIZONTAL_ALIGNMENT_CENTER)
	label.position = pos
	label.size = size
	label.modulate = Color(1.0, 0.92, 0.78)
	app._view_container().add_child(label)


func _draw_hero_detail_section_header(text: String, pos: Vector2, size: Vector2) -> void:
	app._draw_image(UI_COMMON_SECTION, pos, size, true, Color(1, 1, 1, 0.78))
	var label: Label = app._label(text, 13, HORIZONTAL_ALIGNMENT_CENTER)
	label.position = pos
	label.size = size
	label.modulate = Color(1.0, 0.92, 0.78)
	app._view_container().add_child(label)


func _draw_hero_detail_attr(label_text: String, value_text: String, pos: Vector2, scale: float) -> void:
	var label: Label = app._label(label_text, 12)
	label.position = pos
	label.size = Vector2(72, 18)
	label.modulate = Color(0.92, 0.86, 0.80)
	app._view_container().add_child(label)
	var value: Label = app._label(value_text, 12, HORIZONTAL_ALIGNMENT_RIGHT)
	value.position = pos + Vector2(86, 0) * scale
	value.size = Vector2(56, 18)
	value.modulate = Color(1.0, 0.86, 0.60)
	app._view_container().add_child(value)


func _draw_hero_card_stars(rarity: int, pos: Vector2, size: int) -> void:
	if size < 20:
		for i in range(clamp(rarity, 1, 5)):
			app._draw_image(UI_HERO_STAR_SMALL, pos + Vector2(i * float(size), 0), Vector2(size, size), false, Color(1, 1, 1, 0.94))
		return
	for i in range(clamp(rarity, 1, 5)):
		var star_path := UI_COMMON_STAR if size >= 20 else UI_HERO_STAR_SMALL
		app._draw_image(star_path, pos + Vector2(i * (size * 0.74), 0), Vector2(size, size), false, Color(1, 1, 1, 0.96))


func _hero_power(hero: Dictionary) -> int:
	var rarity := int(hero.get("rarity", 1))
	var hero_id := int(hero.get("id", 0))
	var owned := int(app.save.get("owned", {}).get(str(hero_id), 0))
	var level := int(app.save.get("hero_levels", {}).get(str(hero_id), 1))
	var promotion := int(app.save.get("hero_promotions", {}).get(str(hero_id), 0))
	var bond := int(app.save.get("hero_bonds", {}).get(str(hero_id), 0))
	var core_total := _hero_core_total(hero_id)
	var equipment_total := _hero_equipment_total(hero_id)
	var slug_total := _hero_slug_total(hero_id)
	var weapon_level := _hero_weapon_level(hero_id)
	var upstage_step := _hero_upstage_step(hero_id)
	var skill_total := 0
	for skill_index in range(4):
		skill_total += _hero_skill_level(hero_id, skill_index)
	return 2600 + rarity * 920 + max(owned, 1) * 360 + (hero_id % 100) * 13 + level * 45 + promotion * 320 + bond * 60 + skill_total * 28 + core_total * 54 + equipment_total * 42 + slug_total * 36 + weapon_level * 64 + upstage_step * 180


func _owned_hero_count() -> int:
	var owned := _hero_state_dict("owned")
	var count := 0
	for key in owned.keys():
		if int(owned.get(key, 0)) > 0:
			count += 1
	return count


func _camp_hero_count(filter: String) -> int:
	if filter == "all":
		return app.heroes.size()
	var count := 0
	for hero in app.heroes:
		if _hero_camp_key(hero) == filter:
			count += 1
	return count


func _detail_cycle_heroes(hero_id: int) -> Array:
	var filtered: Array = _gallery_filtered_heroes()
	if _hero_index_in_list(filtered, hero_id) >= 0:
		return filtered
	var all_heroes: Array = app.heroes.duplicate(true)
	all_heroes.sort_custom(_sort_gallery_heroes)
	return all_heroes


func _hero_attrs(hero: Dictionary) -> Dictionary:
	var rarity := int(hero.get("rarity", 1))
	var hero_id := int(hero.get("id", 0))
	var level := int(app.save.get("hero_levels", {}).get(str(hero_id), 1))
	var promotion := int(app.save.get("hero_promotions", {}).get(str(hero_id), 0))
	var bond := int(app.save.get("hero_bonds", {}).get(str(hero_id), 0))
	var core_total := _hero_core_total(hero_id)
	var equipment_total := _hero_equipment_total(hero_id)
	var slug_total := _hero_slug_total(hero_id)
	var weapon_level := _hero_weapon_level(hero_id)
	var upstage_step := _hero_upstage_step(hero_id)
	var power := _hero_power(hero)
	return {
		"攻擊": 900 + rarity * 220 + level * 18 + promotion * 70 + equipment_total * 12 + slug_total * 8 + weapon_level * 18 + upstage_step * 30,
		"防禦": 520 + rarity * 150 + level * 10 + promotion * 46 + core_total * 8 + slug_total * 5 + upstage_step * 16,
		"生命": 5200 + rarity * 1280 + level * 160 + promotion * 520 + core_total * 96 + slug_total * 42 + weapon_level * 120 + upstage_step * 160,
		"速度": 92 + rarity * 7 + max(0, int(slug_total / 6)),
		"傷害+": "%d%%" % (10 + rarity * 3 + promotion + int(weapon_level / 5)),
		"命中": "%d%%" % (82 + rarity * 3 + min(bond, 10)),
		"暴擊": "%d%%" % (12 + rarity * 4 + promotion * 2),
		"減免": "%d%%" % (8 + rarity * 2 + int(core_total / 4)),
		"抗暴": "%d%%" % (8 + rarity * 3),
		"戰力": power,
	}


func _hero_unlock_shard_cost(hero: Dictionary) -> int:
	var rarity := int(hero.get("rarity", 1))
	if rarity >= 5:
		return 30
	if rarity >= 4:
		return 20
	return 12


func _hero_state_dict(key: String) -> Dictionary:
	var data = app.save.get(key, {})
	return data if typeof(data) == TYPE_DICTIONARY else {}


func _hero_slot_key(hero_id: int, slot: int) -> String:
	return "%d:%d" % [hero_id, slot]


func _hero_equipment_key(hero_id: int, kind: String, slot: int) -> String:
	return "%d:%s:%d" % [hero_id, kind, slot]


func _hero_single_key(hero_id: int) -> String:
	return str(hero_id)


func _favorite_heroes() -> Array:
	var data = app.save.get("favorite_hero_ids", [])
	return data if typeof(data) == TYPE_ARRAY else []


func _set_hero_notice(text: String) -> void:
	app.save["hero_detail_notice"] = text


func _unlock_hero_with_shards(hero_id: int) -> void:
	var hero: Dictionary = app._hero_by_id(hero_id)
	var key := str(hero_id)
	var shards := _hero_state_dict("shards")
	var owned := _hero_state_dict("owned")
	var cost := _hero_unlock_shard_cost(hero)
	if int(shards.get(key, 0)) < cost:
		_set_hero_notice("碎片不足，召喚需要 %d" % cost)
	else:
		shards[key] = int(shards.get(key, 0)) - cost
		owned[key] = max(1, int(owned.get(key, 0)))
		app.save["shards"] = shards
		app.save["owned"] = owned
		app.save["selected_hero_id"] = hero_id
		_set_hero_notice("已使用碎片召喚")
	app._persist()
	_show_hero_detail(hero_id)


func _set_hero_as_wallpaper(hero_id: int) -> void:
	app.save["selected_hero_id"] = hero_id
	_set_hero_notice("已設為主界面看板")
	app._persist()
	_show_hero_detail(hero_id)


func _set_hero_as_gal(hero_id: int, open_gal := false) -> void:
	app.save["selected_gal_hero_id"] = hero_id
	_set_hero_notice("已設為 Gal 看板")
	app._persist()
	if open_gal:
		app._show_gal()
	else:
		_show_hero_detail(hero_id)


func _toggle_favorite_hero(hero_id: int) -> void:
	var key := str(hero_id)
	var favorites := _favorite_heroes().duplicate()
	if favorites.has(key):
		favorites.erase(key)
		_set_hero_notice("已取消收藏")
	else:
		favorites.append(key)
		_set_hero_notice("已加入收藏")
	app.save["favorite_hero_ids"] = favorites
	app._persist()
	_show_hero_detail(hero_id)


func _train_hero(hero_id: int) -> void:
	var key := str(hero_id)
	var levels := _hero_state_dict("hero_levels")
	var next_level: int = min(120, int(levels.get(key, 1)) + 1)
	levels[key] = next_level
	app.save["hero_levels"] = levels
	_set_hero_notice("培養成功，Lv.%d" % next_level)
	app._persist()
	_show_hero_detail(hero_id)


func _upgrade_hero_core(hero_id: int, slot: int) -> void:
	var levels := _hero_state_dict("hero_core_levels")
	var key := _hero_slot_key(hero_id, slot)
	var next_level: int = min(15, int(levels.get(key, 0)) + 1)
	levels[key] = next_level
	app.save["hero_core_levels"] = levels
	_set_hero_notice("核心位 %d 升至 Lv.%d" % [slot, next_level])
	app._persist()
	_show_hero_detail(hero_id)


func _upgrade_all_hero_cores(hero_id: int) -> void:
	var levels := _hero_state_dict("hero_core_levels")
	for slot in range(1, 5):
		var key := _hero_slot_key(hero_id, slot)
		levels[key] = min(15, int(levels.get(key, 0)) + 1)
	app.save["hero_core_levels"] = levels
	_set_hero_notice("四個核心位已強化")
	app._persist()
	_show_hero_detail(hero_id)


func _hero_core_total(hero_id: int) -> int:
	var levels := _hero_state_dict("hero_core_levels")
	var total := 0
	for slot in range(1, 5):
		total += int(levels.get(_hero_slot_key(hero_id, slot), 0))
	return total


func _hero_equipment_symbol(kind: String) -> String:
	match kind:
		"slug":
			return "源"
		"weapon":
			return "具"
		_:
			return "裝"


func _hero_equipment_level(hero_id: int, kind: String, slot: int) -> int:
	var levels := _hero_state_dict("hero_equipment_levels")
	return int(levels.get(_hero_equipment_key(hero_id, kind, slot), 0))


func _upgrade_hero_equipment(hero_id: int, kind: String, slot: int) -> void:
	var levels := _hero_state_dict("hero_equipment_levels")
	var key := _hero_equipment_key(hero_id, kind, slot)
	var next_level: int = min(20, int(levels.get(key, 0)) + 1)
	levels[key] = next_level
	app.save["hero_equipment_levels"] = levels
	_set_hero_notice("%s槽 %d 升至 Lv.%d" % [_hero_equipment_symbol(kind), slot, next_level])
	app._persist()
	_show_hero_detail(hero_id)


func _upgrade_all_hero_equipment(hero_id: int) -> void:
	var levels := _hero_state_dict("hero_equipment_levels")
	for slot in range(1, 5):
		var key := _hero_equipment_key(hero_id, "equip", slot)
		levels[key] = min(20, int(levels.get(key, 0)) + 1)
	app.save["hero_equipment_levels"] = levels
	_set_hero_notice("灵装已一键强化")
	app._persist()
	_show_hero_detail(hero_id)


func _hero_equipment_total(hero_id: int) -> int:
	var levels := _hero_state_dict("hero_equipment_levels")
	var total := 0
	for slot in range(1, 5):
		total += int(levels.get(_hero_equipment_key(hero_id, "equip", slot), 0))
	return total


func _hero_slug_level(hero_id: int, slot: int) -> int:
	var levels := _hero_state_dict("hero_slug_levels")
	return int(levels.get(_hero_slot_key(hero_id, slot), 0))


func _upgrade_hero_slug(hero_id: int, slot: int) -> void:
	var levels := _hero_state_dict("hero_slug_levels")
	var key := _hero_slot_key(hero_id, slot)
	var next_level: int = min(20, int(levels.get(key, 0)) + 1)
	levels[key] = next_level
	app.save["hero_slug_levels"] = levels
	_set_hero_notice("源神位 %d 升至 Lv.%d" % [slot, next_level])
	app._persist()
	_show_hero_detail(hero_id)


func _upgrade_all_hero_slugs(hero_id: int) -> void:
	var levels := _hero_state_dict("hero_slug_levels")
	for slot in range(1, 5):
		var key := _hero_slot_key(hero_id, slot)
		levels[key] = min(20, int(levels.get(key, 0)) + 1)
	app.save["hero_slug_levels"] = levels
	_set_hero_notice("源神已一键装配")
	app._persist()
	_show_hero_detail(hero_id)


func _hero_slug_total(hero_id: int) -> int:
	var total := 0
	for slot in range(1, 5):
		total += _hero_slug_level(hero_id, slot)
	return total


func _hero_slug_name(hero_id: int, slot: int) -> String:
	var names := ["帕露梦", "星尘灵", "辉羽", "月渊"]
	return str(names[posmod(hero_id + slot, names.size())])


func _hero_slug_attrs(hero_id: int) -> Array:
	var total := _hero_slug_total(hero_id)
	return [
		["攻击", "+%d" % (160 + total * 18)],
		["生命", "+%d" % (900 + total * 95)],
		["防御", "+%d" % (90 + total * 11)],
		["速度", "+%d" % max(1, int(total / 3) + 1)],
	]


func _hero_weapon_level(hero_id: int) -> int:
	var levels := _hero_state_dict("hero_exclusive_weapon_levels")
	return int(levels.get(_hero_single_key(hero_id), 0))


func _upgrade_hero_weapon(hero_id: int) -> void:
	var levels := _hero_state_dict("hero_exclusive_weapon_levels")
	var key := _hero_single_key(hero_id)
	var next_level: int = min(30, int(levels.get(key, 0)) + 1)
	levels[key] = next_level
	app.save["hero_exclusive_weapon_levels"] = levels
	_set_hero_notice("神具锻造至 Lv.%d" % next_level)
	app._persist()
	_show_hero_detail(hero_id)


func _hero_upstage_step(hero_id: int) -> int:
	var steps := _hero_state_dict("hero_upstage_steps")
	return clampi(int(steps.get(_hero_single_key(hero_id), 0)), 0, 6)


func _upgrade_hero_upstage(hero_id: int) -> void:
	var steps := _hero_state_dict("hero_upstage_steps")
	var key := _hero_single_key(hero_id)
	var next_step: int = min(6, int(steps.get(key, 0)) + 1)
	steps[key] = next_step
	app.save["hero_upstage_steps"] = steps
	_set_hero_notice("星格进度 %d/6" % next_step)
	app._persist()
	_show_hero_detail(hero_id)


func _hero_stage_sign_name(hero_id: int) -> String:
	var names := ["天蝎座", "白羊座", "双子座", "狮子座", "天秤座", "星环"]
	return str(names[posmod(hero_id, names.size())])


func _promote_hero(hero_id: int) -> void:
	var key := str(hero_id)
	var shards := _hero_state_dict("shards")
	var promotions := _hero_state_dict("hero_promotions")
	var current := int(promotions.get(key, 0))
	var cost := 10 + current * 10
	if int(shards.get(key, 0)) < cost:
		_set_hero_notice("碎片不足，升星需要 %d" % cost)
	else:
		shards[key] = int(shards.get(key, 0)) - cost
		promotions[key] = current + 1
		app.save["shards"] = shards
		app.save["hero_promotions"] = promotions
		_set_hero_notice("升星成功，星級 +1")
	app._persist()
	_show_hero_detail(hero_id)


func _hero_skill_key(hero_id: int, skill_index: int) -> String:
	return "%d:%d" % [hero_id, skill_index]


func _hero_skill_level(hero_id: int, skill_index: int) -> int:
	var levels := _hero_state_dict("hero_skill_levels")
	return max(1, int(levels.get(_hero_skill_key(hero_id, skill_index), 1)))


func _select_hero_skill(hero_id: int, skill_index: int) -> void:
	app.save["hero_selected_skill_hero"] = hero_id
	app.save["hero_selected_skill"] = clampi(skill_index, 0, 3)
	_set_hero_notice("已選中技能 %d" % (clampi(skill_index, 0, 3) + 1))
	app._persist()
	_show_hero_detail(hero_id)


func _upgrade_hero_skill(hero_id: int, skill_index: int) -> void:
	var levels := _hero_state_dict("hero_skill_levels")
	var key := _hero_skill_key(hero_id, skill_index)
	var next_level: int = min(20, int(levels.get(key, 1)) + 1)
	levels[key] = next_level
	app.save["hero_skill_levels"] = levels
	_set_hero_notice("技能 %d 升至 Lv.%d" % [skill_index + 1, next_level])
	app._persist()
	_show_hero_detail(hero_id)


func _raise_hero_bond(hero_id: int) -> void:
	var key := str(hero_id)
	var bonds := _hero_state_dict("hero_bonds")
	var next_bond: int = min(30, int(bonds.get(key, 0)) + 1)
	bonds[key] = next_bond
	app.save["hero_bonds"] = bonds
	_set_hero_notice("羈絆提升至 Lv.%d" % next_bond)
	app._persist()
	_show_hero_detail(hero_id)


func _hero_index_in_list(list: Array, hero_id: int) -> int:
	for index in range(list.size()):
		var hero: Dictionary = list[index]
		if int(hero.get("id", 0)) == hero_id:
			return index
	return -1

func _gallery_filtered_heroes() -> Array:
	var list := []
	for hero in app.heroes:
		var hero_id := int(hero.get("id", 0))
		var rarity := int(hero.get("rarity", 1))
		var owned := int(app.save.get("owned", {}).get(str(hero_id), 0)) > 0
		var camp := _hero_camp_key(hero)
		var occupation := _hero_occupation_key(hero)
		var include := true
		match gallery_filter:
			"owned":
				include = owned
			"unowned":
				include = not owned
			"r4":
				include = rarity >= 4
			"r3":
				include = rarity == 3
			"r2":
				include = rarity <= 2
			_:
				include = true
		if gallery_filter.begins_with("camp") and camp != gallery_filter:
			include = false
		if gallery_camp_filter != "all" and camp != gallery_camp_filter:
			include = false
		if gallery_occupation_filter != "all" and occupation != gallery_occupation_filter:
			include = false
		if include:
			list.append(hero)
	list.sort_custom(_sort_gallery_heroes)
	return list

func _sort_heroes_by_level(a: Dictionary, b: Dictionary) -> bool:
	var a_id := int(a.get("id", 0))
	var b_id := int(b.get("id", 0))
	var a_owned := int(app.save.get("owned", {}).get(str(a_id), 0)) > 0
	var b_owned := int(app.save.get("owned", {}).get(str(b_id), 0)) > 0
	if a_owned != b_owned:
		return a_owned
	var a_level := int(app.save.get("hero_levels", {}).get(str(a_id), 1))
	var b_level := int(app.save.get("hero_levels", {}).get(str(b_id), 1))
	if a_level != b_level:
		return a_level > b_level
	var a_rarity := int(a.get("rarity", 1))
	var b_rarity := int(b.get("rarity", 1))
	if a_rarity != b_rarity:
		return a_rarity > b_rarity
	var a_power := _hero_power(a)
	var b_power := _hero_power(b)
	if a_power != b_power:
		return a_power > b_power
	return a_id < b_id

func _sort_gallery_heroes(a: Dictionary, b: Dictionary) -> bool:
	var a_id := int(a.get("id", 0))
	var b_id := int(b.get("id", 0))
	var a_owned := int(app.save.get("owned", {}).get(str(a_id), 0)) > 0
	var b_owned := int(app.save.get("owned", {}).get(str(b_id), 0)) > 0
	if a_owned != b_owned:
		return a_owned
	match gallery_sort_mode:
		"level":
			return _sort_heroes_by_level(a, b)
		"power":
			var a_power := _hero_power(a)
			var b_power := _hero_power(b)
			if a_power != b_power:
				return a_power > b_power
		"name":
			var a_name := str(a.get("name", ""))
			var b_name := str(b.get("name", ""))
			if a_name != b_name:
				return a_name < b_name
		_:
			pass
	var a_rarity := int(a.get("rarity", 1))
	var b_rarity := int(b.get("rarity", 1))
	if a_rarity != b_rarity:
		return a_rarity > b_rarity
	return a_id < b_id

func _gallery_sort_label(mode: String) -> String:
	match mode:
		"level":
			return "等級"
		"rarity":
			return "稀有"
		"name":
			return "名稱"
		_:
			return "戰力"

func _hero_camp_key(hero: Dictionary) -> String:
	var hero_id := int(hero.get("id", 0))
	return "camp%d" % ((hero_id % 5) + 1)

func _hero_occupation_key(hero: Dictionary) -> String:
	var hero_id := int(hero.get("id", 0))
	return "occupation%d" % ((int(hero_id / 10) % 5) + 1)


func _hero_camp_label(hero: Dictionary) -> String:
	match _hero_camp_key(hero):
		"camp1":
			return "虚光"
		"camp2":
			return "绝舞"
		"camp3":
			return "灼炎"
		"camp4":
			return "逆卫"
		"camp5":
			return "星殿"
		_:
			return "全部"


func _hero_camp_short_label(hero: Dictionary) -> String:
	var label := _hero_camp_label(hero)
	if label.is_empty():
		return "阵"
	return label.substr(0, 1)


func _hero_occupation_label(hero: Dictionary) -> String:
	match _hero_occupation_key(hero):
		"occupation1":
			return "女武神"
		"occupation2":
			return "辅助"
		"occupation3":
			return "守护"
		"occupation4":
			return "强袭"
		"occupation5":
			return "术式"
		_:
			return "全能"
