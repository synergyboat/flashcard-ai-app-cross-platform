import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  Animated,
  Alert,
  Modal,
  TextInput,
  Dimensions,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { Deck } from '../types';
import GradientButton from './GradientButton';
import { COLORS, TYPOGRAPHY, SHADOWS } from '../config/theme.config';

interface DeckCardProps {
  deck: Deck;
  onPress: (deck: Deck) => void;
  onLongPress?: () => void;
  onDelete?: (deckId: number) => void;
  onEdit?: (deck: Deck) => void;
  isShaking?: boolean;
}

const { width } = Dimensions.get('window');
const cardWidth = (width - 56) / 2;

const DeckCard: React.FC<DeckCardProps> = ({
  deck,
  onPress,
  onLongPress,
  onDelete,
  onEdit,
  isShaking = false,
}) => {
  const [editModalVisible, setEditModalVisible] = useState(false);
  const [deleteModalVisible, setDeleteModalVisible] = useState(false);
  const [editName, setEditName] = useState(deck.name);
  const [editDescription, setEditDescription] = useState(deck.description || '');
  
  const shakeAnimation = new Animated.Value(0);

  React.useEffect(() => {
    if (isShaking) {
      Animated.loop(
        Animated.sequence([
          Animated.timing(shakeAnimation, {
            toValue: -0.04,
            duration: 100,
            useNativeDriver: true,
          }),
          Animated.timing(shakeAnimation, {
            toValue: 0.04,
            duration: 100,
            useNativeDriver: true,
          }),
        ])
      ).start();
    } else {
      shakeAnimation.stopAnimation();
      shakeAnimation.setValue(0);
    }
  }, [isShaking, shakeAnimation]);

  const handlePress = () => {
    if (isShaking) {
      onLongPress?.();
    } else {
      onPress(deck);
    }
  };

  const handleEdit = () => {
    setEditName(deck.name);
    setEditDescription(deck.description || '');
    setEditModalVisible(true);
  };

  const handleSaveEdit = () => {
    if (onEdit && deck.id) {
      onEdit({
        ...deck,
        name: editName,
        description: editDescription,
      });
    }
    setEditModalVisible(false);
  };

  const handleDelete = () => {
    setDeleteModalVisible(true);
  };

  const confirmDelete = () => {
    if (onDelete && deck.id) {
      onDelete(deck.id);
    }
    setDeleteModalVisible(false);
  };

  const renderCardStack = () => (
    <View style={styles.cardStackContainer}>
      {/* Back cards */}
      <View style={[styles.backCard, styles.backCard1]} />
      <View style={[styles.backCard, styles.backCard2]} />
      
      {/* Front card */}
      <View style={styles.frontCard}>
        <Text style={styles.deckName} numberOfLines={3}>
          "{deck.name}"
        </Text>
      </View>
    </View>
  );

  return (
    <>
      <TouchableOpacity
        style={[styles.container, { width: cardWidth }]}
        onPress={handlePress}
        onLongPress={onLongPress}
        activeOpacity={0.8}
      >
        <Animated.View style={{ 
          transform: [{ 
            rotate: shakeAnimation.interpolate({
              inputRange: [-0.04, 0.04],
              outputRange: ['-0.04rad', '0.04rad'],
            })
          }] 
        }}>
          {renderCardStack()}
          
          {isShaking && (
            <TouchableOpacity
              style={styles.editButton}
              onPress={handleEdit}
              activeOpacity={0.8}
            >
              <Ionicons name="pencil-outline" size={20} color={COLORS.TEXT.PRIMARY} />
            </TouchableOpacity>
          )}
        </Animated.View>
      </TouchableOpacity>

      {/* Edit Modal */}
      <Modal
        visible={editModalVisible}
        animationType="slide"
        transparent={true}
        onRequestClose={() => setEditModalVisible(false)}
      >
        <View style={styles.modalOverlay}>
          <View style={styles.modalContent}>
            <View style={styles.modalHandle} />
            
            <View style={styles.modalHeader}>
              <Text style={styles.modalTitle}>Edit Deck</Text>
              <TouchableOpacity onPress={handleDelete}>
                <Text style={styles.deleteText}>Delete</Text>
              </TouchableOpacity>
            </View>

            <View style={styles.inputContainer}>
              <Text style={styles.inputLabel}>Name</Text>
              <TextInput
                style={styles.textInput}
                value={editName}
                onChangeText={setEditName}
                placeholder="Deck name"
              />
            </View>

            <View style={styles.inputContainer}>
              <Text style={styles.inputLabel}>Description</Text>
              <TextInput
                style={styles.textInput}
                value={editDescription}
                onChangeText={setEditDescription}
                placeholder="Deck description"
                multiline
              />
            </View>

            <GradientButton
              title="Save changes"
              onPress={handleSaveEdit}
              style={styles.saveButton}
            />
          </View>
        </View>
      </Modal>

      {/* Delete Confirmation Modal */}
      <Modal
        visible={deleteModalVisible}
        animationType="fade"
        transparent={true}
        onRequestClose={() => setDeleteModalVisible(false)}
      >
        <View style={styles.deleteModalOverlay}>
          <View style={styles.deleteModalContent}>
            <Text style={styles.deleteModalTitle}>Confirm Deletion</Text>
            
            <View style={styles.warningContainer}>
              <Ionicons name="information-circle-outline" size={20} color={COLORS.STATUS.ERROR} />
              <Text style={styles.warningText}>This action cannot be undone.</Text>
            </View>
            
            <Text style={styles.deleteModalText}>
              Are you sure you want to delete this deck?
            </Text>

            <View style={styles.deleteModalButtons}>
              <TouchableOpacity
                style={styles.cancelButton}
                onPress={() => setDeleteModalVisible(false)}
              >
                <Text style={styles.cancelButtonText}>Cancel</Text>
              </TouchableOpacity>
              
              <TouchableOpacity
                style={styles.confirmButton}
                onPress={confirmDelete}
              >
                <Text style={styles.confirmButtonText}>Confirm</Text>
              </TouchableOpacity>
            </View>
          </View>
        </View>
      </Modal>
    </>
  );
};

const styles = StyleSheet.create({
  container: {
    marginBottom: 16,
  },
  cardStackContainer: {
    height: 210,
    position: 'relative',
    shadowColor: COLORS.BORDER.MEDIUM,
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.75,
    shadowRadius: 3.84,
    elevation: 5,
  },
  backCard: {
    position: 'absolute',
    backgroundColor: COLORS.BACKGROUND.CARD,
    borderRadius: 32,
    borderWidth: 0.25,
    borderColor: COLORS.BORDER.MEDIUM,
    width: cardWidth,
  },
  backCard1: {
    width: cardWidth * 0.7,
    height: 180,
    right: 32,
    top: 0,
    transform: [{ rotate: '0.2rad' }],
    ...SHADOWS.CARD,
  },
  backCard2: {
    width: cardWidth * 0.75,
    height: 180,
    left: 20,
    top: 10,
    transform: [{ rotate: '-0.2rad' }],
    ...SHADOWS.CARD,
  },
  frontCard: {
    position: 'absolute',
    width: cardWidth * 0.85,
    height: 200,
    backgroundColor: COLORS.BACKGROUND.CARD,
    borderRadius: 32,
    borderWidth: 0.25,
    borderColor: COLORS.BORDER.MEDIUM,
    // padding: 16,
    justifyContent: 'center',
    alignItems: 'center',
    ...SHADOWS.CARD,
  },
  deckName: {
    fontSize: TYPOGRAPHY.SIZES.SMALL,
    color: COLORS.TEXT.PRIMARY,
    fontWeight: TYPOGRAPHY.WEIGHTS.NORMAL,
    textAlign: 'center',
    lineHeight: TYPOGRAPHY.LINE_HEIGHTS.TIGHT,
  },
  editButton: {
    position: 'absolute',
    top: -8,
    right: -8,
    width: 42,
    height: 42,
    borderRadius: 21,
    backgroundColor: COLORS.BACKGROUND.CARD,
    justifyContent: 'center',
    alignItems: 'center',
    ...SHADOWS.CARD,
  },
  modalOverlay: {
    flex: 1,
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
    justifyContent: 'flex-end',
  },
  modalContent: {
    backgroundColor: COLORS.BACKGROUND.CARD,
    borderTopLeftRadius: 24,
    borderTopRightRadius: 24,
    padding: 20,
    paddingBottom: 40,
    minHeight: '50%',
  },
  modalHandle: {
    width: 40,
    height: 4,
    backgroundColor: COLORS.BORDER.LIGHT,
    borderRadius: 2,
    alignSelf: 'center',
    marginBottom: 16,
  },
  modalHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 20,
  },
  modalTitle: {
    fontSize: TYPOGRAPHY.SIZES.LARGE,
    fontWeight: TYPOGRAPHY.WEIGHTS.BOLD,
    color: COLORS.TEXT.PRIMARY,
  },
  deleteText: {
    fontSize: TYPOGRAPHY.SIZES.SMALL,
    color: COLORS.STATUS.ERROR,
    fontWeight: TYPOGRAPHY.WEIGHTS.NORMAL,
  },
  inputContainer: {
    marginBottom: 16,
  },
  inputLabel: {
    fontSize: TYPOGRAPHY.SIZES.SMALL,
    color: COLORS.TEXT.PRIMARY,
    marginBottom: 8,
    fontWeight: TYPOGRAPHY.WEIGHTS.NORMAL,
  },
  textInput: {
    borderWidth: 1,
    borderColor: COLORS.BORDER.LIGHT,
    borderRadius: 8,
    padding: 12,
    fontSize: TYPOGRAPHY.SIZES.MEDIUM,
    color: COLORS.TEXT.PRIMARY,
    backgroundColor: COLORS.BACKGROUND.CARD,
  },
  saveButton: {
    marginTop: 16,
  },
  deleteModalOverlay: {
    flex: 1,
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  deleteModalContent: {
    backgroundColor: COLORS.BACKGROUND.CARD,
    borderRadius: 12,
    padding: 24,
    margin: 20,
    width: '90%',
  },
  deleteModalTitle: {
    fontSize: TYPOGRAPHY.SIZES.LARGE,
    fontWeight: TYPOGRAPHY.WEIGHTS.BOLD,
    color: COLORS.TEXT.PRIMARY,
    marginBottom: 16,
    textAlign: 'center',
  },
  warningContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: `${COLORS.STATUS.ERROR}20`,
    padding: 8,
    borderRadius: 8,
    marginBottom: 12,
  },
  warningText: {
    fontSize: TYPOGRAPHY.SIZES.SMALL,
    color: COLORS.STATUS.ERROR,
    marginLeft: 8,
  },
  deleteModalText: {
    fontSize: TYPOGRAPHY.SIZES.MEDIUM,
    color: COLORS.TEXT.SECONDARY,
    textAlign: 'center',
    marginBottom: 24,
  },
  deleteModalButtons: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  cancelButton: {
    flex: 1,
    paddingVertical: 12,
    marginRight: 8,
    alignItems: 'center',
  },
  cancelButtonText: {
    fontSize: TYPOGRAPHY.SIZES.MEDIUM,
    color: COLORS.TEXT.PRIMARY,
  },
  confirmButton: {
    flex: 1,
    paddingVertical: 12,
    marginLeft: 8,
    alignItems: 'center',
  },
  confirmButtonText: {
    fontSize: TYPOGRAPHY.SIZES.MEDIUM,
    color: COLORS.STATUS.ERROR,
    fontWeight: TYPOGRAPHY.WEIGHTS.MEDIUM,
  },
});

export default DeckCard;