import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/member_provider.dart';
import '../../../models/member_model.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/app_dropdown.dart';
import '../../../core/widgets/app_snackbar.dart';

/// Screen for enrolling a new library patron or updating existing member records
class AddEditMemberScreen extends StatefulWidget {
  final String? memberId;

  const AddEditMemberScreen({super.key, this.memberId});

  @override
  State<AddEditMemberScreen> createState() => _AddEditMemberScreenState();
}

class _AddEditMemberScreenState extends State<AddEditMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cardIdController = TextEditingController();
  final _addressController = TextEditingController();
  final _maxBooksController = TextEditingController(text: '3');

  String _selectedStatus = 'active';
  bool _isLoading = false;

  bool get isEditing => widget.memberId != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final memberProv = Provider.of<MemberProvider>(context, listen: false);
        final member = memberProv.getMemberById(widget.memberId!);
        if (member != null) {
          setState(() {
            _nameController.text = member.name;
            _emailController.text = member.email;
            _phoneController.text = member.phone;
            _cardIdController.text = member.membershipNumber;
            _addressController.text = member.address;
            _maxBooksController.text = '${member.maxBooksAllowed}';
            _selectedStatus = member.status;
          });
        }
      });
    } else {
      // Auto-generate membership card ID
      _cardIdController.text = 'LIB-2026-${(DateTime.now().millisecondsSinceEpoch % 1000).toString().padLeft(3, '0')}';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cardIdController.dispose();
    _addressController.dispose();
    _maxBooksController.dispose();
    super.dispose();
  }

  void _saveMember() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 300));

    final memberProv = Provider.of<MemberProvider>(context, listen: false);
    final maxBooks = int.tryParse(_maxBooksController.text) ?? 3;

    if (isEditing) {
      final existing = memberProv.getMemberById(widget.memberId!);
      final updated = MemberModel(
        id: widget.memberId!,
        userId: existing?.userId,
        membershipNumber: _cardIdController.text.trim(),
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        status: _selectedStatus,
        maxBooksAllowed: maxBooks,
        joinedDate: existing?.joinedDate ?? DateTime.now(),
      );
      memberProv.updateMember(updated);
      if (mounted) {
        AppSnackbar.showSuccess(context, 'Member information updated.');
        Navigator.pop(context);
      }
    } else {
      final newMember = MemberModel(
        id: 'mem_${DateTime.now().millisecondsSinceEpoch}',
        membershipNumber: _cardIdController.text.trim(),
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        status: _selectedStatus,
        maxBooksAllowed: maxBooks,
        joinedDate: DateTime.now(),
      );
      memberProv.addMember(newMember);
      if (mounted) {
        AppSnackbar.showSuccess(context, 'New member enrolled successfully!');
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Member Profile' : 'Enroll New Member'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Form(
              key: _formKey,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEditing ? 'Update Patron Record' : 'Member Registration',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Provide personal details and specify library borrowing privileges.',
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                      const Divider(height: 32),
                      AppTextField(
                        label: 'Full Name',
                        hint: 'e.g. Clara Oswald',
                        controller: _nameController,
                        prefixIcon: const Icon(Icons.person_outline),
                        validator: (v) => Validators.requiredField(v, 'Full Name'),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              label: 'Email Address',
                              hint: 'clara@university.edu',
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              prefixIcon: const Icon(Icons.email_outlined),
                              validator: Validators.email,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: AppTextField(
                              label: 'Phone Number',
                              hint: '+1 (555) 000-0000',
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              prefixIcon: const Icon(Icons.phone_outlined),
                              validator: (v) => Validators.requiredField(v, 'Phone number'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              label: 'Membership Card ID',
                              hint: 'LIB-2026-XXX',
                              controller: _cardIdController,
                              prefixIcon: const Icon(Icons.badge_outlined),
                              validator: (v) => Validators.requiredField(v, 'Card ID'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: AppDropdown<String>(
                              label: 'Membership Status',
                              value: _selectedStatus,
                              items: const [
                                DropdownMenuItem(value: 'active', child: Text('Active Patron')),
                                DropdownMenuItem(value: 'suspended', child: Text('Suspended')),
                                DropdownMenuItem(value: 'expired', child: Text('Expired')),
                              ],
                              onChanged: (st) {
                                if (st != null) setState(() => _selectedStatus = st);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: AppTextField(
                              label: 'Residential / Campus Address',
                              hint: '10 Downing St, London or Hall 4, Campus',
                              controller: _addressController,
                              prefixIcon: const Icon(Icons.home_outlined),
                              validator: (v) => Validators.requiredField(v, 'Address'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 1,
                            child: AppTextField(
                              label: 'Borrow Limit',
                              hint: '3',
                              controller: _maxBooksController,
                              keyboardType: TextInputType.number,
                              prefixIcon: const Icon(Icons.book_outlined),
                              validator: (v) => Validators.requiredField(v, 'Borrow limit'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 12),
                          AppButton(
                            text: isEditing ? 'Save Changes' : 'Enroll Member',
                            isLoading: _isLoading,
                            onPressed: _saveMember,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
