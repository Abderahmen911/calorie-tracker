import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../models/user_profile_model.dart';

class ProfileScreen extends StatelessWidget {
  final String userId;

  const ProfileScreen({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final userService = UserService();

    return FutureBuilder<UserProfileModel?>(
      future: userService.getUserProfile(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = snapshot.data;
        final userName = user?.name ?? 'Utilisateur';
        final userEmail = user?.email ?? authService.currentUser?.email ?? '';

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 50,
                backgroundColor: Theme.of(context).primaryColor,
                child: Text(
                  userName[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                userName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                userEmail,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),
              if (user != null) _buildStatsCard(user),
              const SizedBox(height: 16),
              _buildMenuCard(
                context,
                icon: Icons.flag_outlined,
                title: 'Objectif de calories',
                subtitle: user != null
                    ? '${user.dailyCalorieGoal.round()} cal/jour'
                    : 'Non défini',
                onTap: () => _showUpdateGoalDialog(context, user),
              ),
              const SizedBox(height: 12),
              _buildMenuCard(
                context,
                icon: Icons.monitor_weight_outlined,
                title: 'Profil santé',
                subtitle: 'Poids, taille, âge',
                onTap: () => _showHealthProfileDialog(context, user),
              ),
              const SizedBox(height: 12),
              _buildMenuCard(
                context,
                icon: Icons.restaurant_outlined,
                title: 'Aliments personnalisés',
                subtitle: 'Ajouter vos propres aliments',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fonctionnalité à venir!'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildMenuCard(
                context,
                icon: Icons.settings_outlined,
                title: 'Paramètres',
                subtitle: 'Préférences de l\'application',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Paramètres à venir!'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Déconnexion'),
                        content: const Text('Voulez-vous vous déconnecter?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Annuler'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text('Déconnexion'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true && context.mounted) {
                      await authService.signOut();
                    }
                  },
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text(
                    'Déconnexion',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsCard(UserProfileModel user) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('Objectif', '${user.dailyCalorieGoal.round()}', 'cal'),
            Container(width: 1, height: 40, color: Colors.grey[300]),
            _buildStatItem('Poids', user.weight > 0 ? '${user.weight.round()}' : '-', 'kg'),
            Container(width: 1, height: 40, color: Colors.grey[300]),
            _buildStatItem('Taille', user.height > 0 ? '${user.height.round()}' : '-', 'cm'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, String unit) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          unit,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).primaryColor,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Future<void> _showUpdateGoalDialog(BuildContext context, UserProfileModel? user) async {
    final controller = TextEditingController(
      text: user?.dailyCalorieGoal.round().toString() ?? '2000',
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Objectif de calories'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Calories par jour',
            suffixText: 'cal',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );

    if (result == true && context.mounted) {
      final newGoal = double.tryParse(controller.text);
      if (newGoal != null) {
        final userService = UserService();
        await userService.updateCalorieGoal(user!.id, newGoal);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Objectif mis à jour!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    }
  }

  Future<void> _showHealthProfileDialog(BuildContext context, UserProfileModel? user) async {
    final weightController = TextEditingController(
      text: user?.weight.toString() ?? '',
    );
    final heightController = TextEditingController(
      text: user?.height.toString() ?? '',
    );
    final ageController = TextEditingController(
      text: user?.age.toString() ?? '',
    );
    String selectedGender = user?.gender ?? 'Homme';
    String selectedActivity = user?.activityLevel ?? 'Modéré';

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Profil santé'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: weightController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Poids',
                    suffixText: 'kg',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: heightController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Taille',
                    suffixText: 'cm',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: ageController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Âge',
                    suffixText: 'ans',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedGender,
                  decoration: InputDecoration(
                    labelText: 'Sexe',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: ['Homme', 'Femme'].map((gender) {
                    return DropdownMenuItem(value: gender, child: Text(gender));
                  }).toList(),
                  onChanged: (value) {
                    setState(() => selectedGender = value!);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedActivity,
                  decoration: InputDecoration(
                    labelText: 'Niveau d\'activité',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: ['Sédentaire', 'Léger', 'Modéré', 'Actif', 'Très actif']
                      .map((activity) {
                    return DropdownMenuItem(value: activity, child: Text(activity));
                  }).toList(),
                  onChanged: (value) {
                    setState(() => selectedActivity = value!);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );

    if (result == true && context.mounted) {
      final weight = double.tryParse(weightController.text) ?? 0;
      final height = double.tryParse(heightController.text) ?? 0;
      final age = int.tryParse(ageController.text) ?? 0;

      final userService = UserService();
      await userService.updateUserProfile(user!.id, {
        'weight': weight,
        'height': height,
        'age': age,
        'gender': selectedGender,
        'activityLevel': selectedActivity,
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil mis à jour!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}