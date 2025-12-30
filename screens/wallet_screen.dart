import 'package:flutter/material.dart';
import '../widgets/wallet_card.dart';
import '../services/mock_wallet_service.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  // --- ШҮҮЛТҮҮРИЙН ХУВЬСАГЧУУД ---
  DateTimeRange? _selectedDateRange;
  
  // Олон сонголт хийх боломжтой Set ашиглана
  final Set<String> _selectedFilters = {'all'}; 

  // Шүүлтүүрийн төрлүүд ба шошго
  final Map<String, String> _filterOptions = {
    'all': 'Бүгд',
    'money': 'Мөнгө',
    'points': 'Оноо',
    'expense': 'Зарлага',
    'income': 'Орлого',
    'purchase': 'Худалдан авалт',
    'conversion': 'Хөрвүүлэлт',
  };

  // --- ШҮҮЛТҮҮРИЙН ЛОГИК ---
  List<TransactionModel> _getFilteredTransactions(List<TransactionModel> allTransactions) {
    return allTransactions.where((tx) {
      // 1. Огноо шүүлтүүр
      bool dateMatch = true;
      if (_selectedDateRange != null) {
        final start = DateTime(
          _selectedDateRange!.start.year, 
          _selectedDateRange!.start.month, 
          _selectedDateRange!.start.day
        );
        final end = DateTime(
          _selectedDateRange!.end.year, 
          _selectedDateRange!.end.month, 
          _selectedDateRange!.end.day, 
          23, 59, 59
        );
        
        dateMatch = tx.date.isAfter(start.subtract(const Duration(seconds: 1))) && 
                    tx.date.isBefore(end);
      }

      // 2. Төрөл шүүлтүүр
      if (_selectedFilters.contains('all')) return dateMatch;

      bool currencyMatch = true;
      bool hasCurrencyFilter = _selectedFilters.contains('money') || _selectedFilters.contains('points');
      if (hasCurrencyFilter) {
        bool matchMoney = _selectedFilters.contains('money') && !tx.isPoints;
        bool matchPoints = _selectedFilters.contains('points') && tx.isPoints;
        currencyMatch = matchMoney || matchPoints;
      }

      bool flowMatch = true;
      bool hasFlowFilter = _selectedFilters.contains('expense') || _selectedFilters.contains('income');
      if (hasFlowFilter) {
        bool matchExpense = _selectedFilters.contains('expense') && tx.isExpense;
        bool matchIncome = _selectedFilters.contains('income') && !tx.isExpense;
        flowMatch = matchExpense || matchIncome;
      }

      bool categoryMatch = true;
      bool hasCategoryFilter = _selectedFilters.contains('purchase') || _selectedFilters.contains('conversion');
      if (hasCategoryFilter) {
        bool matchPurchase = _selectedFilters.contains('purchase') && 
                             (tx.title.toLowerCase().contains('худалдан') || tx.detail?.toLowerCase().contains('худалдан') == true);
        bool matchConversion = _selectedFilters.contains('conversion') && 
                               (tx.title.toLowerCase().contains('хөрвүүлэлт') || tx.detail?.toLowerCase().contains('хөрвүүлэлт') == true);
        categoryMatch = matchPurchase || matchConversion;
      }

      return dateMatch && currencyMatch && flowMatch && categoryMatch;
    }).toList();
  }

  // --- ШҮҮЛТҮҮРИЙН ЦОНХ ХАРУУЛАХ ---
  void _showFilterModal() {
    DateTimeRange? tempDateRange = _selectedDateRange;
    Set<String> tempFilters = Set.from(_selectedFilters);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E), 
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        side: BorderSide(color: Colors.white10, width: 1), 
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            
            void toggleFilter(String key) {
              setModalState(() {
                if (key == 'all') {
                  tempFilters.clear();
                  tempFilters.add('all');
                } else {
                  tempFilters.remove('all');
                  if (tempFilters.contains(key)) {
                    tempFilters.remove(key);
                  } else {
                    tempFilters.add(key);
                  }
                  if (tempFilters.isEmpty) tempFilters.add('all');
                }
              });
            }

            // Огноо сонгох функц (Монгол хэлээр)
            Future<void> pickDateRange() async {
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2023),
                lastDate: DateTime.now().add(const Duration(days: 1)),
                initialDateRange: tempDateRange,
                
                // ▼▼▼ МОНГОЛ ХЭЛНИЙ ТОХИРГОО ▼▼▼
                locale: const Locale('mn', 'MN'), 
                saveText: "СОНГОХ",
                cancelText: "БОЛИХ",
                confirmText: "СОНГОХ",
                helpText: "ХУГАЦАА СОНГОХ",
                fieldStartLabelText: "Эхлэх огноо",
                fieldEndLabelText: "Дуусах огноо",
                errorFormatText: "Буруу формат",
                errorInvalidText: "Буруу огноо",
                // ▲▲▲ ▲▲▲

                builder: (context, child) => _buildCalendarTheme(child!),
              );
              if (picked != null) {
                setModalState(() => tempDateRange = picked);
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 20, 
                right: 20, 
                top: 25, 
                bottom: MediaQuery.of(context).viewInsets.bottom + 30
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Толгой хэсэг
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Шүүлтүүр",
                        style: TextStyle(
                          fontSize: 22, 
                          fontWeight: FontWeight.bold, 
                          color: Colors.white
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            tempDateRange = null;
                            tempFilters = {'all'};
                          });
                        },
                        child: const Text("Цэвэрлэх", style: TextStyle(color: Colors.grey)),
                      )
                    ],
                  ),
                  const SizedBox(height: 25),

                  // 1. ОГНОО СОНГОХ ХЭСЭГ
                  Row(
                    children: [
                      // Эхлэх огноо
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Эхлэх огноо:", style: TextStyle(color: Colors.grey, fontSize: 12)),
                            const SizedBox(height: 8),
                            _buildDateBox(
                              date: tempDateRange?.start,
                              onTap: pickDateRange, // Нэг функц дуудна
                            ),
                          ],
                        ),
                      ),
                      
                      // Сум
                      const Padding(
                        padding: EdgeInsets.fromLTRB(10, 20, 10, 0),
                        child: Icon(Icons.arrow_forward, color: Colors.white70, size: 20),
                      ),

                      // Дуусах огноо
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Дуусах огноо:", style: TextStyle(color: Colors.grey, fontSize: 12)),
                            const SizedBox(height: 8),
                            _buildDateBox(
                              date: tempDateRange?.end,
                              onTap: pickDateRange, // Нэг функц дуудна
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 15),

                  // 2. ГҮЙЛГЭЭНИЙ ТӨРӨЛ
                  const Text("Гүйлгээний төрөл:", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 15),
                  
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _filterOptions.entries.map((entry) {
                      bool isSelected = tempFilters.contains(entry.key);
                      return FilterChip(
                        label: Text(entry.value),
                        selected: isSelected,
                        onSelected: (_) => toggleFilter(entry.key),
                        
                        backgroundColor: Colors.transparent,
                        selectedColor: Colors.white,
                        checkmarkColor: Colors.black,
                        showCheckmark: false,
                        
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.black : Colors.white70,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isSelected ? Colors.white : Colors.white24, 
                            width: 1.5
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 40),

                  // 3. "ШҮҮХ" ТОВЧ
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white, 
                        side: const BorderSide(color: Colors.white, width: 1.5), 
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)
                        ),
                        elevation: 5,
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedDateRange = tempDateRange;
                          _selectedFilters.clear();
                          _selectedFilters.addAll(tempFilters);
                        }); 
                        Navigator.pop(context);
                      },
                      child: const Text("Шүүх", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --- UI HELPER: Огноо харуулах хайрцаг ---
  Widget _buildDateBox({DateTime? date, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white30, width: 1),
        ),
        child: Center(
          child: Text(
            // Монгол формат: 2025.12.01
            date == null 
                ? "— . — . —" 
                : "${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}",
            style: const TextStyle(
              color: Colors.white, 
              fontSize: 16, 
              fontWeight: FontWeight.bold,
              letterSpacing: 1
            ),
          ),
        ),
      ),
    );
  }

  // --- UI HELPER: Календарийн загвар ---
  Widget _buildCalendarTheme(Widget child) {
    return Theme(
      data: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(
          primary: Colors.white, 
          onPrimary: Colors.black, 
          surface: Color(0xFF1E1E1E), 
          onSurface: Colors.white, 
          secondary: Colors.grey,
        ),
        dialogBackgroundColor: const Color(0xFF1E1E1E),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: Colors.white),
        ),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isFilterActive = _selectedDateRange != null || !_selectedFilters.contains('all');

    return SingleChildScrollView(
      padding: const EdgeInsets.only(
        left: 20, right: 20, top: 100, bottom: 100
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const WalletCard(),

          const SizedBox(height: 30),

          // ГАРЧИГ
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Гүйлгээний түүх",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Stack(
                children: [
                  IconButton(
                    onPressed: _showFilterModal,
                    icon: const Icon(Icons.tune, color: Colors.grey),
                    tooltip: "Шүүлтүүр",
                  ),
                  if (isFilterActive)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.blueAccent,
                          shape: BoxShape.circle
                        ),
                      ),
                    )
                ],
              ),
            ],
          ),
          
          if (isFilterActive) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: [
                if (_selectedDateRange != null)
                  _buildActiveFilterChip(
                    "${_selectedDateRange!.start.month}/${_selectedDateRange!.start.day} - ${_selectedDateRange!.end.month}/${_selectedDateRange!.end.day}",
                    () => setState(() => _selectedDateRange = null)
                  ),
                ..._selectedFilters.where((f) => f != 'all').map((f) => 
                  _buildActiveFilterChip(
                    _filterOptions[f]!, 
                    () => setState(() {
                      _selectedFilters.remove(f);
                      if (_selectedFilters.isEmpty) _selectedFilters.add('all');
                    })
                  )
                ),
              ],
            ),
          ],
          
          const SizedBox(height: 15),

          // ГҮЙЛГЭЭНИЙ ЖАГСААЛТ
          ValueListenableBuilder<List<TransactionModel>>(
            valueListenable: MockWalletService().transactionsNotifier,
            builder: (context, allTransactions, child) {
              
              final filteredList = _getFilteredTransactions(allTransactions);

              if (filteredList.isEmpty) {
                return Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      Icon(Icons.history, color: Colors.grey[800], size: 60),
                      const SizedBox(height: 10),
                      Text(
                        isFilterActive 
                            ? "Шүүлтүүрт таарах гүйлгээ олдсонгүй" 
                            : "Одоогоор гүйлгээ хийгдээгүй байна",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true, 
                itemCount: filteredList.length,
                itemBuilder: (context, index) {
                  return _buildTransactionItem(filteredList[index]);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFilterChip(String label, VoidCallback onRemove) {
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 11, color: Colors.white)),
      backgroundColor: Colors.white10,
      deleteIcon: const Icon(Icons.close, size: 14, color: Colors.white54),
      onDeleted: onRemove,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide.none),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildTransactionItem(TransactionModel tx) {
    String dateStr = "${tx.date.month}/${tx.date.day} ${tx.date.hour}:${tx.date.minute.toString().padLeft(2, '0')}";

    Color amountColor = tx.isExpense ? const Color(0xFFFF4B4B) : const Color(0xFF00E676);
    IconData icon = tx.isExpense ? Icons.north_east : Icons.south_west;
    
    Color bgIconColor;
    if (tx.isPoints) {
      bgIconColor = Colors.orange.withOpacity(0.15);
    } else {
      bgIconColor = tx.isExpense ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ]
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: bgIconColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              tx.isPoints ? Icons.star : icon, 
              color: tx.isPoints ? Colors.orange : amountColor, 
              size: 22
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tx.detail ?? "Гүйлгээ",
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${tx.isExpense ? '-' : '+'}${tx.amount} ${tx.isPoints ? 'P' : '₮'}",
                style: TextStyle(
                  color: tx.isPoints ? Colors.orange : amountColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                dateStr,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}